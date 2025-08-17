#include <WiFi.h>
#include <HTTPClient.h>
#include <NTPClient.h>
#include <ArduinoJson.h>
#include <TimeLib.h>

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 32400, 60000);

// 카카오 API 정보
const char *host = "https://kapi.kakao.com/v2/api/talk/memo/default/send";
#define APP_KEY "카카오 앱 키" // 고유 REST API Key
#define KAKAO_TOKEN "카카오 토큰"
String FireIndex = "B2_5"; // 불꽃센서에서 전달받은 String


// Wi-Fi 정보 설정
const char* ssid = "WIFI-SSID";  
const char* password = "WIFI-PW";  /

// 구글 API 정보
const char* apiKey = "구글 앱 키";  // Google Geolocation API 키
const char* serverName = "https://www.googleapis.com/geolocation/v1/geolocate?key=";
float latitude = 0;
float longitude = 0;

void setup() {
  Serial.begin(115200);
  
  // Wi-Fi 연결
  int cnt = 0;
  Serial.print("Connecting to Wi-Fi");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED && cnt < 10) {
    delay(500);
    Serial.print(".");
    cnt++;
  }
  Serial.println("\nConnected to Wi-Fi");
  timeClient.begin(); 
  getLocation();
  send_kakao_message();
}

void loop() {}

// 화재 발생 일시
String fireTime(){
  timeClient.update();
  unsigned long epochTime = timeClient.getEpochTime();
  setTime(epochTime);
  return String(year()) + "." + String(month()) + "." 
  + String(day()) + " " + String(timeClient.getFormattedTime());  
}

void getLocation() {
  if (WiFi.status() == WL_CONNECTED) {  // Wi-Fi 연결 상태 확인
    // 주변 Wi-Fi 스캔
    int n = WiFi.scanNetworks();
    if (n == 0) Serial.println("No networks found");
    else 
    {
      Serial.println("Found networks:");
      String jsonBody = "{\"wifiAccessPoints\":[";
      for (int i = 0; i < n; i++) {
        String macAddress = WiFi.BSSIDstr(i);  // MAC 주소
        int rssi = WiFi.RSSI(i);  // 신호 강도
        jsonBody += "{\"macAddress\": \"" + macAddress + "\", \"signalStrength\": " + String(rssi) + "}";
        if (i < n - 1) jsonBody += ",";
        Serial.println("  " + macAddress + " (RSSI: " + String(rssi) + ")");
      }
      jsonBody += "]}";

      // Google Geolocation API 요청 URL 설정
      HTTPClient http;
      String url = String(serverName) + apiKey;
      http.begin(url);
      http.addHeader("Content-Type", "application/json");
      int httpCode = http.POST(jsonBody);

      // 응답 처리
      if (httpCode > 0) {
        String payload = http.getString();
        Serial.println("Response:");
        Serial.println(payload);

        // JSON 파싱
        DynamicJsonDocument doc(1024);
        deserializeJson(doc, payload);
        
        // 위도와 경도 추출
        latitude = doc["location"]["lat"];
        longitude = doc["location"]["lng"];
        Serial.print("Latitude: ");
        Serial.println(latitude, 7);
        Serial.print("Longitude: ");
        Serial.println(longitude, 7);
      } 
      else {
        Serial.print("Error on HTTP request: ");
        Serial.println(httpCode);
      }

      http.end();  // HTTP 연결 종료
    }
  } 
  else
    Serial.println("Wi-Fi not connected");
}

void send_kakao_message() {
  HTTPClient http;

  if (!http.begin(host)) {
    Serial.println("\nfailed to begin http\n");
    return; // 오류 발생 시 함수 종료
  }
  // 카카오톡 API 양식
  http.addHeader("Authorization", "Bearer " + String(KAKAO_TOKEN)); 
  http.addHeader("Content-Type", "application/x-www-form-urlencoded"); 

  StaticJsonDocument<200> doc;
  String mapUrl = "https://www.google.com/maps?q=" + String(latitude, 7) + "," + String(longitude, 7);
  doc["object_type"] = "text";
  doc["text"] = FireIndex + " 에서 화재 발생!\n" 
  + "\n화재 발생 일시:\n" + fireTime() 
  + "\n\n지도에서 위치 확인: " + mapUrl;
  doc["link"]["web_url"] = mapUrl;
  doc["link"]["mobile_web_url"] = mapUrl;
  doc["button_title"] = "위치 보기";

  // JSON 객체를 문자열로 변환하고 URL 인코딩 처리
  String jsonString;
  serializeJson(doc, jsonString);
  String data = "template_object=" + jsonString;
  Serial.println(data); // 데이터 출력

  // POST 요청
  int http_code = http.sendRequest("POST", data); 
  Serial.print("HTTP Response code: ");
  Serial.println(http_code); // 응답 코드 출력

  if (http_code > 0)
    Serial.println(http.getString()); // GET 응답
  else
    Serial.println("Error on HTTP request"); // 오류 출력
  http.end(); // 요청 종료
}
