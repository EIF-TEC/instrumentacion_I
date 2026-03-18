bool M = 0;
bool Mp = 0;
bool E = 0;
bool D = 0;
bool B = 0;
bool I = 0;
bool EM1 = 0;
bool EM2 = 0;
bool EM1p = 1;
bool EM2p = 0;

String input = "x";

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop()
{
  while(Serial.available()) input = Serial.readStringUntil('\n');

  if (input == "b"){
    Serial.println("boton");
    B = 1;
  }

  if (input == "d"){
    Serial.println("direccion");
    D = !D;
    Serial.print("D: ");
    Serial.println(D);
  }

  if (input == "e"){
    Serial.println("fin");
    E = !E;
    Serial.print("E: ");
    Serial.println( E );
  }

  if (input == "i"){
    Serial.println("inicio");
    I = !I;
    Serial.print("I: ");
    Serial.println(I);
  }

  EM1 = ( (EM2p && (B || (D && E) || (!D && I) ) ) || EM1p ) && !(EM1p && B);

  EM2 = ( (EM1p && B ) || EM2p ) && !(EM2p && (B || (D && E) || (!D && I) )); 

  M = EM2;

  if (M != Mp) {
    Serial.print("EM1: ");
    Serial.print(EM1);
    Serial.print(", EM2: ");
    Serial.println(EM2);
    Serial.print("M: ");
    Serial.println(M);
  }
  digitalWrite(LED_BUILTIN, M);  // turn the LED on (HIGH is the voltage level)
 
  input = "x";
  B = 0;
  EM1p = EM1;
  EM2p = EM2;
  Mp = M;
}