pragma solidity ^0.7.0;


contract MintToken{
    
    string public name; //토큰의 이름
    string public symbol; //토큰의 심볼(=화폐 단위)
    uint8 public decimals = 18; //소수점 단위를 의미한다. 디폴트 18로 이더 단위와 일치하 설정해놓는다. 
    uint256 public totalSupply; //발행되는 토큰의 개수

    mapping (address => uint256) public balanceOf; //모든 계좌들의 잔액.
    mapping (address => mapping (address => uint256)) public allowance; // 첫번째 address에서 두번째 address가 토큰을 보내도록 승안하고 허용된 인출 토큰량을 저장.
                                                                        //즉 제3자인 두번째 address가 첫번째 address에 있는 토큰을 다른곳으로 보낼 수 있는것.
                                                                        // allowance는 1회당 전송 승인량이 아니라 전체 승인량이다.
                                                                         


    
    constructor( uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public{
       name = tokenName;
       symbol = tokenSymbol;
       totalSupply = initialSupply * (10 ** uint256(decimals)); // 총 발행량을 deciamal 단위로 만든다.
       balanceOf[msg.sender] = totalSupply; //스마트 컨트랙트를 실행시킨 사람이 처음 발행된 토큰을 모두 가진다.

    }
    

    function _transfer(address _from, address _to, uint _value) internal{
    //internal transfer 함수


        //보내는 사람이 충분한 잔액을 가지고 있는지 확인한다.
        require(balanceOf[_from] >= _value);

        //받는 사람 잔액 오버플로우를 확인한다.
        require(balanceOf[_to] + _value > balanceOf[_to]);

        //보내는 사람의 토큰과 받는 사람의 토큰의 합을 전송후에 문제가 없는지 확인하기 위해 저장해 둔다.
        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        //보내는 사람으로부터 토큰을 인출한다.
        balanceOf[_from] -= _value;

        //받는 사람에게 토큰을 준다.
        balanceOf[_to] += _value;

        // 전송 전의 보내는 사람과 받는 사람의 토큰 합과 전송 후의 토큰합을 비교 함으로써 토큰 전송 결과에 버그가 없는지 확인한다.
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);


    }

    function transfer(address _to, uint256 _value) public returns(bool success){
    //_value 만큼의 토큰을 _to에게 컨트랙트를 실행한 사람의 계좌에서 보낸다.

        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
    //msg.sender가(approve로 승인된) _value 만큼의 토큰을 _to에게 다른 사람의(_from) 계좌에서 보낸다.

        require(_value <= allowance[_from][msg.sender] ); //전송하려는 _value값이 승인된 양이하인지 확인한다.
        allowance[_from][msg.sender] -= _value;//승인된 인출량에서 얼마만큼 인출되면 그 값만큼 allowance의 _value에서 빼주어야 한다.
        _transfer(_from, _to, _value); 
        return true;

    }

    function approve(address _spender, uint256 _value) public returns(bool success){
    //msg.sender(approve 함수를 실행한 사람의 주소, 즉 승인은 본인만 할 수 있게됨.)는  _spender(제 3자)가 msg.sender의 계좌에서 _value 만큼의 토큰 전송 할수 있는 권한을 준다.
        allowance[msg.sender][_spender] = _value; 
        return true;

    }


    function burn(uint256 _value) public returns (bool success){
    //스마트 컨트랙트를 실행한 사람(msg.sender)의토큰을 파괴한다.
    require(balanceOf[msg.sender] >= _value); //sender의 토큰이 충분한지 확인한다.
    balanceOf[msg.sender] -= _value; //sender의 계좌에서 value값만큼 토큰 제거
    totalSupply -= _value; //총 토큰량에서 value 값만큼 토큰 제거
    return true;
    }


    function burnFrom(address _from, uint256 _value) public returns(bool success){
    //다른 사람의 토큰을 제거한다.
        require(balanceOf[_from] >= _value); //_from의 토큰이 없애고자하는 _value값 이상인지 확인한다.
        require(_value <= allowance[_from][msg.sender]);// _value값이 msg.sender가 _from에서 없앨 수 있는 허용된 토큰양 이하인지 확인한다. 
        balanceOf[_from] -= _value; //_from의 계좌에서 value값 만큼 토큰 제거
        allowance[_from][msg.sender] -= _value;//msg.sender가 _from에서 인출할 수 있는 토큰의 양을 _value만큼 줄인다.
        totalSupply -= _value; //총 토큰량에서 value 값만큼 토큰 제거
        return true;
    }




}

