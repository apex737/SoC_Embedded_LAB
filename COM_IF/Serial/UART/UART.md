## Universal Asynchronous Reciever/Transmitter
* 클럭이 없는 대신 Baud-Rate(9600, 115200...)를 맞춤 
* MS 구조가 없고, __Tx/Rx/GND 3개의 선을 기본으로 사용__
* 추가적으로 Ready 관련 Strob가 붙을 수 있어서 3~5 line이 사용됨

#### 구성
> 8N1 데이터 프레임이 가장 일반적임
* Start bit
* Data bit (8bit)
* Parity bit (N; 잘 안씀)
* End bit (1bit)
#### 작동방식
* 일반적으로 LSB -> MSB 순으로 전송
* HIGH를 IDLE 상태로 간주하고, 처음으로 LOW로 떨어지는 것이 Start
* Start bit (LOW) 이후, __payload 1Byte__ 전송
* 옵션에 따라 parity가 있으면 넣은 뒤에, 아니면 바로 HIGH로 복귀하여 End
* __즉, parity가 없으면 10bit가 1-Frame(8N1)이 된다.__
#### 구현
1) Bit-Banging (하드코딩)
2) UART-Peri (주로 Interrupt 방식)
> Ex. STM32 HAL 드라이버; HAL_UART_Receive_IT(&huart, pData, Size) 
#### 한계
* 1:1 통신만 가능
* 더 느린쪽에 baud-rate을 맞춰야 함
* Reciever의 ACK-bit 없음; __수신양호__ 확인불가 
