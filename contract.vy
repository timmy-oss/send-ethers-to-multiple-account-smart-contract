# @title Send Ethers to Multiple Accounts Once Smart Contract
# @notice With this smart contract, you can send ethers to more than one wallet adddresses at once, you only need to enter the addresses and the amount to send
# @notice to each address and the contract takes care of the rest. The contract selfdestructs after the transactions have been completed
# @author Timileyin Pelumi http://github.com/timmy-oss
# @dev Written in Vyper



event Sent:
    receiver : address
    amount : uint256

event SentAll:
    pass

admin : address
amounts : HashMap[ uint256, uint256]
addresses  : HashMap[uint256, address]
notEmpty : bool
lax  : bool

@payable
@external
def __init__():
    self.admin = msg.sender
    self.notEmpty = False
    self.lax = False

@external
@payable
def __default__():
    pass

@external
def addBeneficiaries(  _addresses : address[64], _amounts : uint256[64], _lax : bool = False ):
    assert msg.sender == self.admin
    self.lax = _lax
    for i in range(64):
        if( not self.lax ):
            assert _addresses[i] != ZERO_ADDRESS, 'Invalid Address Detected'
            assert _amounts[i] > 0, 'Amount must be greater zero'

        self.addresses[i] = _addresses[i]
        self.amounts[i] = _amounts[i]
    self.notEmpty = True


@external
def payOut( _destroyAfter : bool =  False):
    assert msg.sender == self.admin
    assert self.notEmpty , 'Receipients list is empty'
    totalAmount : uint256 = 0
    for i in range(64):
        totalAmount += self.amounts[i]
    assert self.balance >= totalAmount , 'Insufficient funds'
    for i in range(64):
        if(self.lax):
            if(( self.addresses[i] == ZERO_ADDRESS) or ( not self.amounts[i] > 0)):
                continue
            else:
                raise("Either ZERO_ADDRESS or INVALID_AMOUNT")
        send( self.addresses[i], self.amounts[i] )
        log Sent(self.addresses[i], self.amounts[i])
    log SentAll()
    self.notEmpty = False
    if ( _destroyAfter):
        selfdestruct(self.admin)









