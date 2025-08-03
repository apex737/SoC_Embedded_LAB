## <APB: Advanced Peri-Bus>
* ARM사가 개발한 저성능 장치 전용 버스 I/F
* APB 브릿지(Master) -> 저성능 장치(Slave)
  
#### 인터페이스
* __write__    : 0(Read), 1(Write)
* __sel, addr__: 어떤 slave의 어떤 레지스터? (몇동 몇호?)
* __en(M)__       : 데이터 받을 준비됨??
* __ready(S)__    : ㅇㅇ 
* __wdata, rdata__
> 마스터는 통신에 필요한 값(sel, addr, write, data)을 세팅하며, Slave에게 1클럭의 읽을 시간을 준다. <br>
> 그 이상이 필요한 경우 Slave가 ready로 필요한만큼 Stall(WAIT)하는 구조이다.
* __state__
	* __IDLE__
 	* __SETUP__: __Set__ sel, addr, data & __en, ready LOW__
	* __ACCESS__: SETUP + __en HIGH__

