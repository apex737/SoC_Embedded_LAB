### <AHB: Advanced High Performance Bus>
### 1) 2-phase (addr, data)
- __addr phase__: Set addr, sel, write signals
- __data phase__: Transfer Data
- __2-phase__ 구조를 통해 data-pipelining과 multi-transfer을 구현할 수 있게된다.

### 2) Additional Signals ( APB+ )
#### Burst-Mode
* HTRANS[1:0] (state)
  * __IDLE__ 
  * __BUSY__: Burst Transfer 중 인터럽트 
  * __NONSEQ__: 단일 데이터 또는 burst의 첫 전송
  * __SEQ__: 연속 데이터 전송
* HBURST[2:0]
  * Case
    * 0: 단일 데이터
    * 1: N-연속(beat) 순차 전송
    * 2/3: 4-beat wrap/순차 전송
    * 4/5: 8-beat wrap/순차 전송
    * 6/7: 16-beat wrap/순차 전송
  * Wrap
    * 순환 버퍼의 Boundary를 지정하여 그 내부에서 주소를 증가하면서 접근
    * Boundary = HSize * HBURST_beat
      * Ex. HSize = 8Byte, HBURST = 2 (4-beat), StartAddr = 0x3C
      * Boundary  = 8 * 4 = 32Byte
      * Range     = [0x00 ~ 0x1F], [0x20 ~ 0x3F], [0x40 ~ 0x5F]...
      * HAddr     = 0x3C -> ~0x44~ -> 0x24 -> 0x3C ...
  
* HSIZE[2:0]
  * 

* HPROT[3:0]

#### Arbiter
