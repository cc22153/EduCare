/* ESP32 — captura 60 amostras (1 por segundo) de BPM + ADXL345
   — PULSE_PIN: GPIO34 (ADC1) recomendado com Wi-Fi
   — Página web em / que atualiza a cada 1s e mostra JSON
   — Envia JSON completo (bpm array + accel array) para API ao final do minuto
   — Requer biblioteca Adafruit_ADXL345_U
*/

#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <Adafruit_ADXL345_U.h>
#include <time.h>

// ========== CONFIGURAÇÕES ==========
const char* WIFI_SSID = "iPhone de Jotta";
const char* WIFI_PASS = "12345678";

const char* API_URL = "https://overflatly-nonutilized-fermin.ngrok-free.dev/analisar"; // -> troque quando tiver endpoint

#define PULSE_PIN 34                // GPIO34 (ADC1) — recomendado com Wi-Fi ON
const unsigned long SAMPLE_INTERVAL_MS = 1000UL; // 1s
const int SAMPLES_PER_MINUTE = 60;

// ajuste de alerta imediato
const int BPM_ALERT_THRESHOLD = 160; // se ultrapassar, envia alerta IMEDIATO

// ========== OBJETOS ==========
Adafruit_ADXL345_Unified accel = Adafruit_ADXL345_Unified(12345);
WebServer server(80);

// ========== BUFFERS ==========
int bpmArray[SAMPLES_PER_MINUTE];
float accelArray[SAMPLES_PER_MINUTE][3];
int sampleIndex = 0;
bool bufferFull = false;

// ========== ESTADO ==========
unsigned long lastSampleMillis = 0;
unsigned long lastSendMillis = 0;
float bpmFiltered = 80.0; // valor inicial
int lastReportedBpm = 0;

String alunoId = "6a600844-ba32-4d55-a0cd-32c04d3d0786"; // ajuste/coloque o id real do aluno aqui (ou via BLE/EEPROM)
String latestJson = "{}"; // JSON exibido na página

// ========== FUNÇÕES AUXILIARES ==========
int readRawBPM() {
  // Leitura analógica do sensor de pulso (valor 0..4095)
  int raw = analogRead(PULSE_PIN);
  // Mapear para faixa de batimentos (apenas aproximação para sensor simulado)
  int mapped = map(raw, 0, 4095, 50, 160);
  mapped = constrain(mapped, 30, 220);
  return mapped;
}

float readAccelMagnitude(float &x, float &y, float &z) {
  if (!accel.begin()) {
    // se não tiver ADXL, simula algo pequeno
    x = random(-20, 20) / 100.0;
    y = random(-20, 20) / 100.0;
    z = 9.8 + random(-10, 10) / 100.0;
    return sqrt(x*x + y*y + z*z);
  } else {
    sensors_event_t ev;
    accel.getEvent(&ev);
    x = ev.acceleration.x;
    y = ev.acceleration.y;
    z = ev.acceleration.z;
    return sqrt(x*x + y*y + z*z);
  }
}

int readFilteredBPM() {
  int raw = readRawBPM();
  // EMA (Exponential Moving Average) para suavizar
  const float alpha = 0.15;
  bpmFiltered = bpmFiltered * (1.0 - alpha) + raw * alpha;

  int cand = (int)round(bpmFiltered);

  // limitar variação brusca por amostra (clamp)
  if (lastReportedBpm != 0) {
    int delta = cand - lastReportedBpm;
    const int maxDelta = 15; // bpm por segundo máximo de variação permitido
    if (delta > maxDelta) cand = lastReportedBpm + maxDelta;
    if (delta < -maxDelta) cand = lastReportedBpm - maxDelta;
  }
  lastReportedBpm = cand;
  return cand;
}

String isoTimestampNow() {
  time_t now;
  time(&now);
  struct tm timeinfo;
  gmtime_r(&now, &timeinfo); // usar UTC
  char buf[30];
  // Ex: 2025-11-07T14:30:00Z
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buf);
}

// Monta o JSON completo conforme você pediu
String buildMinuteJson() {
  String j = "{";
  j += "\"aluno_id\":\"" + alunoId + "\",";
  j += "\"timestamp\":\"" + isoTimestampNow() + "\",";
  j += "\"bpm\":[";
  for (int i = 0; i < SAMPLES_PER_MINUTE; i++) {
    j += String(bpmArray[i]);
    if (i < SAMPLES_PER_MINUTE - 1) j += ",";
  }
  j += "],";

  j += "\"accel\":[";
  for (int i = 0; i < SAMPLES_PER_MINUTE; i++) {
    j += "[";
    j += String(accelArray[i][0], 3) + "," + String(accelArray[i][1], 3) + "," + String(accelArray[i][2], 3);
    j += "]";
    if (i < SAMPLES_PER_MINUTE - 1) j += ",";
  }
  j += "]";

  j += "}";
  return j;
}

// POST simples (bloqueante)
void postJsonToApi(const String &json) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi desconectado — nao envia para API.");
    return;
  }
  HTTPClient http;
  http.begin(API_URL);
  http.addHeader("Content-Type", "application/json");
  // se for Supabase REST, adicione apikey/Authorization aqui (não coloque chaves públicas em código compartilhado)
  int code = http.POST(json);
  Serial.printf("POST %s -> code %d\n", API_URL, code);
  http.end();
}

// Envia alerta imediato (usando mesmo endpoint, mas pode mudar)
void sendImmediateAlert(const String &reason, int value) {
  if (WiFi.status() != WL_CONNECTED) return;
  HTTPClient http;
  http.begin(API_URL);
  http.addHeader("Content-Type", "application/json");
  String j = "{";
  j += "\"aluno_id\":\"" + alunoId + "\",";
  j += "\"timestamp\":\"" + isoTimestampNow() + "\",";
  j += "\"alert\":true,";
  j += "\"motivo\":\"" + reason + "\",";
  j += "\"valor\":" + String(value);
  j += "}";
  int code = http.POST(j);
  Serial.printf("ALERTA POST -> code %d\n", code);
  http.end();
}

// ===== Web server handlers
void handleRoot() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send_P(200, "text/html", R"rawliteral(
<!doctype html>
<html><head>
<meta charset="utf-8"><title>Pulseira - Dados</title>
<style>body{font-family:Arial;background:#eaf6ff;color:#01394a;padding:18px}pre{background:#fff;padding:12px;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.08)}h1{color:#0077b6}</style>
</head><body>
<h1>Pulseira (ESP32) — Dados em tempo real</h1>
<p>Atualiza a cada 1s. Mostra última amostra e arrays do minuto.</p>
<pre id="json">{}</pre>
<script>
async function fetchData(){ try{ const r=await fetch('/data'); const t=await r.text(); document.getElementById('json').textContent=t;}catch(e){document.getElementById('json').textContent='Erro: '+e;} }
setInterval(fetchData,1000);
fetchData();
</script>
</body></html>
)rawliteral");
}

void handleData() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", latestJson);
}

void setupServer() {
  server.on("/", handleRoot);
  server.on("/data", handleData);
  server.begin();
  Serial.println("Webserver iniciado em porta 80");
}

// ==== setup NTP
void setupTime() {
  configTime(0, 0, "pool.ntp.org", "time.google.com");
  // espera 2s para sincronizar
  Serial.print("Sincronizando NTP");
  time_t start = millis();
  while (time(nullptr) < 1600000000 && millis() - start < 10000) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("");
}

// ====== SETUP / LOOP ======
void setup() {
  Serial.begin(115200);
  delay(100);

  // inicia ADXL345 (se disponível)
  if (!accel.begin()) {
    Serial.println("ADXL345 NAO ENCONTRADO — usando simulacao de accel.");
  } else {
    Serial.println("ADXL345 OK.");
    accel.setRange(ADXL345_RANGE_16_G);
  }

  // WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.printf("Conectando a WiFi '%s' ...", WIFI_SSID);
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
    Serial.print(".");
    delay(500);
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi conectado. IP: " + WiFi.localIP().toString());
  } else {
    Serial.println("\nFalha ao conectar WiFi (OK, ainda teremos pagina local via AP se quiser).");
  }

  setupTime();
  setupServer();

  // inicializa buffers com zeros
  for (int i = 0; i < SAMPLES_PER_MINUTE; i++) {
    bpmArray[i] = (int) bpmFiltered;
    accelArray[i][0] = accelArray[i][1] = accelArray[i][2] = 0.0;
  }
  latestJson = "{}";

  lastSampleMillis = millis();
  lastSendMillis = millis();
}

void loop() {
  server.handleClient();

  unsigned long now = millis();
  if (now - lastSampleMillis >= SAMPLE_INTERVAL_MS) {
    lastSampleMillis = now;

    // ler BPM filtrado
    int bpm = readFilteredBPM();

    // ler acelerometro (ou simular)
    float ax=0, ay=0, az=0;
    if (accel.begin()) {
      readAccelMagnitude(ax, ay, az);
    } else {
      // simula um pouquinho
      ax = random(-20,20)/100.0;
      ay = random(-20,20)/100.0;
      az = 9.8 + random(-10,10)/100.0;
    }

    // armazena
    bpmArray[sampleIndex] = bpm;
    accelArray[sampleIndex][0] = ax;
    accelArray[sampleIndex][1] = ay;
    accelArray[sampleIndex][2] = az;

    // monta JSON parcial para mostrar na página (última amostra + se estiver acumulando)
    String partial = "{";
    partial += "\"last_sample\":{";
    partial += "\"bpm\":" + String(bpm) + ",";
    partial += "\"accel\":[" + String(ax,3) + "," + String(ay,3) + "," + String(az,3) + "]";
    partial += "},";
    partial += "\"accumulated_count\":" + String(sampleIndex + 1);
    partial += "}";
    latestJson = partial;

    Serial.printf("Amostra %d — BPM: %d — Accel: %.3f,%.3f,%.3f\n", sampleIndex+1, bpm, ax, ay, az);

    // checa alerta imediato
    if (bpm >= BPM_ALERT_THRESHOLD) {
      Serial.println("ALERTA CRITICO! Enviando alerta imediato...");
      sendImmediateAlert("bpm_critico", bpm);
    }

    sampleIndex++;
    if (sampleIndex >= SAMPLES_PER_MINUTE) {
      sampleIndex = 0;
      bufferFull = true;
    }
  }

  // quando buffer completo (1 minuto de dados)
  if (bufferFull) {
    // monta JSON completo
    String fullJson = buildMinuteJson();
    Serial.println("JSON a enviar:");
    Serial.println(fullJson);

    // envia para API
    postJsonToApi(fullJson);

    // disponibiliza o JSON na página (mostra agregado)
    latestJson = "{ \"last_aggregate\": " + fullJson + " }";

    bufferFull = false;
    lastSendMillis = millis();
  }

  delay(5); // leve pausa
}
