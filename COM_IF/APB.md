## <APB: Advanced Peri-Bus>
- APB 브릿지(M) -> 저성능 장치(S)
- write
- sel, addr(cs) : 어떤 slave의 어떤 레지스터?
> 몇동 몇호? 
- en/ready: M->S / S->M strob
- wdata, rdata
* state
	* __IDLE__
 	* __SETUP__:
  		* Set sel, addr, data
    		* en, ready LOW	 
	* __ACCESS__: SETUP + en
		* __WAIT__: SETUP + en + ~ready
- 마스터는 통신에 필요한 데이터를 보내면서 1클럭의 유예를 주고 그 이상이 필요한 경우 slave가 ready로 Stall 하는 구조
