pragma solidity 0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint);
  function transferFrom(address from, address to, uint value)public returns (bool ok);
  function approve(address spender, uint value)public returns (bool ok);
  function transfer(address to, uint value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract BITRON is ERC20
{ using SafeMath for uint256;
    // Name of the token
    string public constant name = "BITRON";

    // Symbol of token
    string public constant symbol = "BTN";
    uint8 public constant decimals = 9;
    uint public _totalsupply = 50000000 * 10 ** 9; // 50 Million total supply // muliplies dues to decimal precision
    address public owner;                    // Owner of this contract
    uint256 no_of_tokens;
    uint256 bonus_token;
    uint256 total_token;
    uint256 tokensold;
    bool stopped = false;
    uint256 public startItoTimestamp; 
    uint256 public currentPerTokenPrice;
    uint256 public startPricePerToken;
    uint256 constant priceICO  = 70; // price is in cents
    uint256 constant pricePRE  = 20;
    uint256 constant price1  = 100;
    uint256 public pre_startdate;
    uint256 public ico_startdate;
    uint256 public  priceCalculationFactor;
    address public ethFundMain = 0x1e6d1Fc2d934D2E4e2aE5e4882409C3fECD769dF; 

    uint256 pre_enddate;
    uint256 ico_enddate;
    uint256 public spendtoken;
    uint256 maxCap_PRE;
    uint256 maxCap_ICO1;
    uint256 maxCap_ICO2;
    uint256 maxCap_ICO3;
    uint c1;
    uint c2;
    uint c;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    uint public priceFactor;

    
     enum Stages {
        NOTSTARTED,
        PREICO,
        ICO,
        PAUSED,
        ENDED
    }
    Stages public stage;
    
    modifier atStage(Stages _stage) {
        if (stage != _stage)
            // Contract not in expected state
            revert();
        _;
    }
    
     modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
  
   function BITRON(uint256 EtherPriceFactor) public
    {
        require(EtherPriceFactor != 0);
        owner = msg.sender;
        balances[owner] = 27500000 * 10 **9; // 27.5 million to owner
        stage = Stages.NOTSTARTED;
        priceFactor = EtherPriceFactor;
        Transfer(0, owner, balances[owner]);
    }
  
   function () public payable 
    {
        require(stage != Stages.ENDED);
        require(!stopped && msg.sender != owner);
            if( stage == Stages.PREICO && now <= pre_enddate )
            { 
                no_of_tokens = ((msg.value).mul(priceFactor.mul(100)).div(pricePRE)).div(10 **9);
               bonus_token = ((no_of_tokens).mul(50)).div(100);
               total_token = no_of_tokens + bonus_token;
               transferTokens(msg.sender,total_token);
        
              }
           else if( stage == Stages.ICO && now <= ico_enddate )
            { 
                c1= getCurrentPrice();
          
                 c2= getCurrentPrice2();
               
                
                if(c1>c2){
                    currentPerTokenPrice = c1;
                     
                } else {
                    
                    currentPerTokenPrice = c2;
                    
                }
                
            
                  no_of_tokens = (msg.value.mul(priceFactor.mul(100)).div(currentPerTokenPrice)).div(10 **9);
                 spendtoken = (spendtoken).add(no_of_tokens);
                  bonus_token = ((no_of_tokens).mul(50)).div(100);
                  total_token = no_of_tokens + bonus_token;
                  transferTokens(msg.sender,total_token);
                 
                    // sendtokens(msg.sender, msg.value);
              
            }
            else{
             revert();
            }
      
    }
    
    // price distribution based on token sold
    function getCurrentPrice2() private returns (uint256 cp)
    {
        uint price = 70; // cent
         c = spendtoken / 10**15;
        if(c == 3) {
            price = 100;
        } else if( c > 3) {
            price = 100 + ((c-2)/3) * 50;
        } else {
            price += c * 10;
        }
        return price;
    }
    
    
    // price distribution based on time decay
    function getCurrentPrice() private returns (uint256 cp)
        {
           
             priceCalculationFactor = (block.timestamp.sub(ico_startdate)).div(432000); //time period
            if(priceCalculationFactor <4)
            {
                currentPerTokenPrice = (priceICO).add(priceCalculationFactor.mul(10));
            }
            if(priceCalculationFactor >= 4)
            {
                currentPerTokenPrice = (price1).add((priceCalculationFactor.sub(3)).mul(50));
            }
            return currentPerTokenPrice;
          
        }
         function sendtokens(address investor,uint amount) private 
        {
              no_of_tokens = (amount.mul(priceFactor.mul(100)).div(currentPerTokenPrice));
             spendtoken = (spendtoken).add(no_of_tokens);
              bonus_token = ((no_of_tokens).mul(50)).div(100);
              total_token = no_of_tokens + bonus_token;
              transferTokens(investor,total_token);
        }
             
    function start_PREICO() public onlyOwner atStage(Stages.NOTSTARTED)
      {
          stage = Stages.PREICO;
          stopped = false;
          maxCap_PRE = 1500000 * 10 **9;  // 1(pre) + .5(bonus) = 1.5 million
          balances[address(this)] = maxCap_PRE;
          pre_startdate = now;
          pre_enddate = now + 14 days;
          Transfer(0, address(this), balances[address(this)]);
          }
      
      function start_ICO() public onlyOwner atStage(Stages.PREICO)
      {
         
         require(now > pre_enddate || balances[address(this)] == 0);
          stage = Stages.ICO;
          stopped = false;
          maxCap_ICO1 = 21000000 * 10 **9; // 14(ico) + 7(bonus) = 21 million
          balances[address(this)] = balances[address(this)].add(maxCap_ICO1) ;
          ico_startdate = now;
          ico_enddate = now + 30 days;
          Transfer(0, address(this), balances[address(this)]);
      }
 
     
    // called by the owner, pause ICO
    function PauseICO() external onlyOwner
    {
        stopped = true;
       }

    // called by the owner , resumes ICO
    function ResumeICO() external onlyOwner
    {
        stopped = false;
      }
   

   function end_ICO() external onlyOwner atStage(Stages.ICO)
     {
        
         require(now > ico_enddate || balances[address(this)] == 0);
         stage = Stages.ENDED;
         _totalsupply = (_totalsupply).sub(balances[address(this)]);
         balances[address(this)] = 0;
         Transfer(address(this), 0 , balances[address(this)]);
    }

    // what is the total supply of the ech tokens
     function totalSupply() public view returns (uint256 total_Supply) {
         total_Supply = _totalsupply;
     }
    
    // What is the balance of a particular account?
     function balanceOf(address _owner)public view returns (uint256 balance) {
         return balances[_owner];
     }
    
    // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom( address _from, address _to, uint256 _amount )public returns (bool success) {
     require( _to != 0x0);
     require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
     balances[_from] = (balances[_from]).sub(_amount);
     allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
     balances[_to] = (balances[_to]).add(_amount);
     Transfer(_from, _to, _amount);
     return true;
         }
    
   // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount)public returns (bool success) {
         require( _spender != 0x0);
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
         require( _owner != 0x0 && _spender !=0x0);
         return allowed[_owner][_spender];
   }

     // Transfer the balance from owner's account to another account
     function transfer(address _to, uint256 _amount)public returns (bool success) {
        require( _to != 0x0);
        require(balances[msg.sender] >= _amount && _amount >= 0);
        balances[msg.sender] = (balances[msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(msg.sender, _to, _amount);
             return true;
         }
    
          // Transfer the balance from owner's account to another account
    function transferTokens(address _to, uint256 _amount) private returns(bool success) {
        require( _to != 0x0);       
        require(balances[address(this)] >= _amount && _amount > 0);
        balances[address(this)] = (balances[address(this)]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(address(this), _to, _amount);
        return true;
        }
    
    function drain() external onlyOwner {
        ethFundMain.transfer(this.balance);
    }
    
}