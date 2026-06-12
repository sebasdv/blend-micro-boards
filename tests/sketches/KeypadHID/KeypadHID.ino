// Keypad gaming USB HID — 4 switches Cherry MX (caso de uso real del proyecto)
#include <Keyboard.h>

const int PIN_W = A0;
const int PIN_A = A1;
const int PIN_S = A2;
const int PIN_D = A3;

const char TECLA_W = 'w';
const char TECLA_A = 's';
const char TECLA_S = 'd';
const char TECLA_D = 'f';

bool estadoW = HIGH;
bool estadoA = HIGH;
bool estadoS = HIGH;
bool estadoD = HIGH;

void setup() {
  pinMode(PIN_W, INPUT_PULLUP);
  pinMode(PIN_A, INPUT_PULLUP);
  pinMode(PIN_S, INPUT_PULLUP);
  pinMode(PIN_D, INPUT_PULLUP);
  pinMode(13, OUTPUT);

  delay(1000);
  Keyboard.begin();

  digitalWrite(13, HIGH);
  delay(100);
  digitalWrite(13, LOW);
  delay(100);
  digitalWrite(13, HIGH);
}

void procesar(int pin, bool &estado, char tecla) {
  bool lectura = digitalRead(pin);
  if (lectura != estado) {
    estado = lectura;
    if (estado == LOW) {
      Keyboard.press(tecla);
    } else {
      Keyboard.release(tecla);
    }
  }
}

void loop() {
  procesar(PIN_W, estadoW, TECLA_W);
  procesar(PIN_A, estadoA, TECLA_A);
  procesar(PIN_S, estadoS, TECLA_S);
  procesar(PIN_D, estadoD, TECLA_D);
}
