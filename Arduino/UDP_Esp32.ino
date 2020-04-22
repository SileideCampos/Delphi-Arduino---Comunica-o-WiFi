#include <M5Stack.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <DHT12.h>
#include <Wire.h>

const char* ssid = "seu-login";
const char* senha = "sua-senha";
unsigned int localPort = 3333;
char pacote[6];

WiFiUDP conexao;
DHT12 dht12;

void setup() {
  Serial.begin(9600);
  Wire.begin();
  M5.begin();

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, senha);
  while(WiFi.waitForConnectResult() != WL_CONNECTED){
    M5.Lcd.println("Não Conecatado");
    WiFi.begin(ssid, senha);
    delay(10);
  }
  M5.Lcd.clear();
  M5.Lcd.setTextSize(5);
  M5.Lcd.setCursor(10,10);
  M5.Lcd.println(WiFi.localIP());
  
  conexao.begin(localPort);
}

void loop() {
  int tamanhoPacote = conexao.parsePacket();
  if (tamanhoPacote) {
    conexao.read(pacote, 6);

    if (strcmp("piscar", pacote) == 0){
      M5.Lcd.clear();
      M5.Lcd.fillScreen(GREEN);
      M5.Lcd.setTextColor(WHITE);
      M5.Lcd.setCursor(10,10);
      M5.Lcd.println(pacote);
    }else if (strcmp("temp", pacote) == 0){
      float temp = dht12.readTemperature();
      conexao.beginPacket(conexao.remoteIP(), conexao.remotePort());
      conexao.printf("%2.2f*C", temp);
      conexao.endPacket();
      M5.Lcd.clear();
      M5.Lcd.setCursor(10,10);
      M5.Lcd.printf("%2.2f*C", temp);
    }
    memset(pacote, 0, 6);    
  }
  conexao.flush();
}
