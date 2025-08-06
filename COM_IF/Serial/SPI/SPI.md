- 전이중(Full-Duplex), __단일 마스터 I/F__
- CLK, MISO, MOSI, __CS (Slave 수에 비례)__
- case({CPOL, CPHA})에 따른 4가지 MODE가 존재
  - CPOL은 IDLE이 0인가 1인가 나타냄
  - CPHA는 어떤 Edge에서 읽고 쓸것인지 나타냄
    - __0:__     IDLE LOW; 이전 클럭 negedge(2-Edge)에서 dout, posedge(1-Edge)에서 din  
    - __1:__     IDLE LOW; posedge(1-Edge)에서 dout, negedge(2-Edge)에서 din
    - __2:__     IDLE HIGH; 이전 클럭 posedge(2-Edge)에서 dout, negedge(1-Edge)에서 din
    - __3:__     IDLE HIGH; negedge(1-Edge)에서 dout, posedge(2-Edge)에서 din

### I2C와 비교한 장점
1) CS선을 활용하여 불필요한 Slave 전력 소모 방지
2) 거대한 루프(Circular Buffer)와 이를 구성하는 Shift-Reg 및 MISO/MOSI
* Shift MReg -- MOSI_LINE -- Shift SReg -- MISO_LINE -- (Loop)
* 이 모든 과정이 단방향 Shift를 통해 구현됨 
