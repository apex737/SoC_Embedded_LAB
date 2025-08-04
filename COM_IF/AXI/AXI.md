## <AXI:  Advanced eXtensible Interface>
### AHB-AXI 공통점
* READY/VALID
* addr/data phase 분리 (pipelining)
* burst mode

### AHB-AXI 차이점
* SEQ 상태에서 첫번째 addr만 전송
* R/W data/addr 채널 분리
	* 각각의 channel에는 ID(TAG)가 존재
		* multiple-issue(Superscalar) 지원
  * Master는 OOOC를 위한 ROB-like-Buffer를 가짐
  * Slave는 OOOI를 위한 RS-like-Buffer를 가짐
    * AHB의 Arbiter 기반 SPLIT 대신 OOOE를 사용하므로 더 빠름 

### 채널별 신호 구성
<AW/AR>
- __id__
- __ready/valid__
- addr
- len
- size
- burst 

<W/RDATA/WRESP>
- __id__
- __ready/valid__
- data
- last
- resp

Write Transaction
