// Keypad gaming USB HID — 4 switches Cherry MX (caso de uso real del proyecto)
// Cableado: A0..A3 -> switch -> GND, con pull-up interno (INPUT_PULLUP).
// Con debounce: un Cherry MX rebota ~5 ms; sin filtrar, cada rebote genera
// press/release extra -> teclas dobles/fantasma. 5 ms es imperceptible en gaming.
#include <Keyboard.h>

const unsigned long DEBOUNCE_MS = 5;

struct Tecla {
  uint8_t pin;
  char codigo;
  bool estado;          // estado estable confirmado (HIGH = suelta, LOW = presionada)
  bool lecturaPrevia;   // ultima lectura cruda de digitalRead
  unsigned long cambio; // millis() del ultimo cambio de la lectura cruda
};

Tecla teclas[] = {
  { A0, 'w', HIGH, HIGH, 0 },
  { A1, 's', HIGH, HIGH, 0 },
  { A2, 'd', HIGH, HIGH, 0 },
  { A3, 'f', HIGH, HIGH, 0 },
};
const uint8_t N = sizeof(teclas) / sizeof(teclas[0]);

void setup() {
  for (uint8_t i = 0; i < N; i++) {
    pinMode(teclas[i].pin, INPUT_PULLUP);
  }
  pinMode(13, OUTPUT);

  delay(1000);
  Serial.begin(115200);  // CDC USB: no bloquear esperando monitor, el keypad debe funcionar solo
  Keyboard.begin();
  Serial.println("KeypadHID listo (con debounce)");

  digitalWrite(13, HIGH);
  delay(100);
  digitalWrite(13, LOW);
  delay(100);
  digitalWrite(13, HIGH);
}

void loop() {
  unsigned long ahora = millis();
  for (uint8_t i = 0; i < N; i++) {
    bool lectura = digitalRead(teclas[i].pin);

    // Reinicia el cronometro cada vez que la lectura cruda cambia (rebote o ruido).
    if (lectura != teclas[i].lecturaPrevia) {
      teclas[i].lecturaPrevia = lectura;
      teclas[i].cambio = ahora;
    }

    // Solo confirma el cambio si la lectura se mantuvo estable DEBOUNCE_MS.
    if ((ahora - teclas[i].cambio) >= DEBOUNCE_MS && lectura != teclas[i].estado) {
      teclas[i].estado = lectura;
      if (lectura == LOW) {
        Keyboard.press(teclas[i].codigo);
        Serial.print("press ");
      } else {
        Keyboard.release(teclas[i].codigo);
        Serial.print("release ");
      }
      Serial.println(teclas[i].codigo);
    }
  }
}
