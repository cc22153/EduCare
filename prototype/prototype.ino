#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_ADXL345_U.h>

// Cria objeto do acelerômetro
Adafruit_ADXL345_Unified accel = Adafruit_ADXL345_Unified(12345);

void setup() {
  Serial.begin(115200);
  if (!accel.begin()) {
    Serial.println("Não foi possível iniciar o ADXL345. Verifique a conexão!");
    while (1);
  }
  
  // Ajuste da faixa de medição (+/- 2, 4, 8, 16g)
  accel.setRange(ADXL345_RANGE_16_G);
  Serial.println("ADXL345 iniciado com sucesso!");
}

void loop() {
  sensors_event_t event;
  accel.getEvent(&event);

  // Valores do acelerômetro
  float x = event.acceleration.x;
  float y = event.acceleration.y;
  float z = event.acceleration.z;

  // Calcula intensidade do movimento
  float intensidade = abs(x) + abs(y) + abs(z);

  // Simula batimentos baseados na intensidade
  int bpm = 60 + intensidade * 5; // ajuste o fator conforme necessário
  if (bpm > 200) bpm = 200; // limite máximo

  // Dispara alerta se bpm > 120
  bool alerta = bpm > 120;

  // Envia para o app/protótipo
  Serial.print("X:"); Serial.print(x);
  Serial.print(",Y:"); Serial.print(y);
  Serial.print(",Z:"); Serial.print(z);
  Serial.print(",BPM:"); Serial.print(bpm);
  Serial.print(",Alerta:"); Serial.println(alerta);

  delay(500); // Atualiza 2x por segundo
}
