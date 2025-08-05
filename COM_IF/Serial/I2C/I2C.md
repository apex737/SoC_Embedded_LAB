- 多:多 통신 지원
- 반이중방식 
- 모든 Slave는 addr을 가짐
- Vdd에 Pull-up 저항이 연결된 구조

비트프레임
Start
* SCL이 HIGH일 때 SDA를 HIGH -> LOW
* SCL이 HIGH -> LOW

SDA: 모델, SCL: 사진사
1) SCL이 LOW 일때만 SDA 변경 (모델이 포즈를 변경)
2) posedge SCL에서 SDA 읽기 (사진사가 셔터를 누름)

마스터의 확인 의무
1) SCL 확인
- 목적: Slave와의 타이밍 동기화 (Clock Stretching)
- 마스터가 SCLK을 High로 만든 이후 버스-SCLK과 비교
- LOW이면 버스 Stall

2) SDA 확인 의무
- 목적: 버스 소유권 중재 
- SCL-posedge에서 Send-bit와 Bus-State가 같나?
- 다르면 버스 양보 (Yield)

sel bit-seq
R/W
ACK
addr bit-seq + ACK
Data1 bit-seq + ACK
Data2 bit-seq + ACK
...
Stop

NACK이 뜨면 전송을 중단하거나 재시작

잘 이해했는지 확인
* Start는 SCLK이 HIGH 일때, SDA가 HIGH -> LOW로 떨어지는것
* Start 이후, 경합하는 마스터는 Sel_bitSeq를 MSB -> LSB 순으로 전송
* 버스 소유권을 두고 경쟁할 때 Wired-AND 원리에 따른 중재가 일어남
* 즉, 어느 하나라도 LOW라면 버스의 상태는 LOW
* 중재: 마스터들이 전송한 bit와 버스에서 읽히는 bit를 비교
	* A: 0001010, B: 0000101, C: 0000111
	* 3th-CLK까지는 0으로 같음
	* 4th-CLK에서 A 탈락 (&100b = 0; 불일치)
		* 탈락한 마스터는 SDA/SCL 상태를 HIGH-Z(입력모드)로 만듦 
	* 6th-CLK에서 C 탈락 (&101b = 0; 불일치)
	* B가 버스 소유
	* B의 STOP 신호 감지 이후 A,C가 버스를 두고 재경합
	* 결과적으로 더 작은 주소 Slave 우선 (B -> C -> A)
* 마찬가지의 원리로, 더 오랫동안 LOW를 유지하는 느린 CLK에 맞춰서
버스의 속도가 결정됨

< 클럭 스트레칭 >
Slave의 Not Ready 신호: SCL을 LOW로 잡는 행동으로 표현됨

Master는 SCL-posedge에서 데이터를 읽고 LOW에서 데이터를 변경
Master의 속도를 Slave가 따라가지 못하는 경우 Slave가 SCL을 LOW로 내려서, 버스를 STALL
AHB의 HSPLIT과 달리, 오래 걸리는 Slave-Task 문제의 해법이 따로없음
2-wire의 구현의 간단함을 취하고 고성능을 포기 (trade-off)
SW-드라이버에서 Timeout-IT를 통해 무한 Delay를 방어하는 방법 정도뿐


