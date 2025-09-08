/**
 *Submitted for verification at BscScan.com on 2025-08-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* === BEGIN Flat OpenZeppelin Essentials === */

/* Context */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
    function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

/* IERC20 */
interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address to,uint256 amount) external returns(bool);
    function allowance(address owner,address spender) external view returns(uint256);
    function approve(address spender,uint256 amount) external returns(bool);
    function transferFrom(address from,address to,uint256 amount) external returns(bool);
    event Transfer(address indexed from,address indexed to,uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

/* IERC20Metadata */
interface IERC20Metadata is IERC20 {
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
}

/* ERC20 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address=>uint256) private _balances;
    mapping(address=>mapping(address=>uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_){
        _name=name_;
        _symbol=symbol_;
    }

    function name() public view virtual override returns(string memory){return _name;}
    function symbol() public view virtual override returns(string memory){return _symbol;}
    function decimals() public view virtual override returns(uint8){return 18;}
    function totalSupply() public view virtual override returns(uint256){return _totalSupply;}
    function balanceOf(address account) public view virtual override returns(uint256){return _balances[account];}

    function transfer(address to,uint256 amount) public virtual override returns(bool){
        _transfer(_msgSender(),to,amount);
        return true;
    }

    function allowance(address owner,address spender) public view virtual override returns(uint256){return _allowances[owner][spender];}
    function approve(address spender,uint256 amount) public virtual override returns(bool){
        _approve(_msgSender(),spender,amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns(bool){
        _spendAllowance(from,_msgSender(),amount);
        _transfer(from,to,amount);
        return true;
    }

    function increaseAllowance(address spender,uint256 addedValue) public virtual returns(bool){
        _approve(_msgSender(),spender,_allowances[_msgSender()][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender,uint256 subtractedValue) public virtual returns(bool){
        uint256 currentAllowance=_allowances[_msgSender()][spender];
        require(currentAllowance>=subtractedValue,"ERC20: decreased allowance below zero");
        unchecked{_approve(_msgSender(),spender,currentAllowance-subtractedValue);}
        return true;
    }

    function _transfer(address from,address to,uint256 amount) internal virtual {
        require(from!=address(0),"ERC20: transfer from zero");
        require(to!=address(0),"ERC20: transfer to zero");
        uint256 fromBalance=_balances[from];
        require(fromBalance>=amount,"ERC20: transfer exceeds balance");
        unchecked{_balances[from]=fromBalance-amount;}
        _balances[to]+=amount;
        emit Transfer(from,to,amount);
    }

    function _mint(address account,uint256 amount) internal virtual {
        require(account!=address(0),"ERC20: mint to zero");
        _totalSupply+=amount;
        _balances[account]+=amount;
        emit Transfer(address(0),account,amount);
    }

    function _burn(address account,uint256 amount) internal virtual {
        require(account!=address(0),"ERC20: burn from zero");
        uint256 accountBalance=_balances[account];
        require(accountBalance>=amount,"ERC20: burn exceeds balance");
        unchecked{_balances[account]=accountBalance-amount;}
        _totalSupply-=amount;
        emit Transfer(account,address(0),amount);
    }

    function _approve(address owner,address spender,uint256 amount) internal virtual{
        require(owner!=address(0),"ERC20: approve from zero");
        require(spender!=address(0),"ERC20: approve to zero");
        _allowances[owner][spender]=amount;
        emit Approval(owner,spender,amount);
    }

    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual{
        uint256 currentAllowance=allowance(owner,spender);
        if(currentAllowance!=type(uint256).max){
            require(currentAllowance>=amount,"ERC20: insufficient allowance");
            unchecked{_approve(owner,spender,currentAllowance-amount);}
        }
    }
}

/* ERC20Burnable */
abstract contract ERC20Burnable is ERC20 {
    function burn(uint256 amount) public virtual {_burn(_msgSender(),amount);}
    function burnFrom(address account,uint256 amount) public virtual{
        _spendAllowance(account,_msgSender(),amount);
        _burn(account,amount);
    }
}

/* Ownable */
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
    constructor(){_transferOwnership(_msgSender());}
    function owner() public view virtual returns(address){return _owner;}
    modifier onlyOwner(){require(owner()==_msgSender(),"Ownable: caller is not owner");_;}
    function transferOwnership(address newOwner) public virtual onlyOwner{
        require(newOwner!=address(0),"Ownable: new owner zero");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual{
        address oldOwner=_owner;
        _owner=newOwner;
        emit OwnershipTransferred(oldOwner,newOwner);
    }
}

/* ReentrancyGuard */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED=1;
    uint256 private constant _ENTERED=2;
    uint256 private _status;
    constructor(){_status=_NOT_ENTERED;}
    modifier nonReentrant(){
        require(_status!=_ENTERED,"ReentrancyGuard: reentrant call");
        _status=_ENTERED;
        _;
        _status=_NOT_ENTERED;
    }
}

/* IERC721 */
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns(address);
}

/* SafeERC20 */
library SafeERC20 {
    function safeTransfer(IERC20 token,address to,uint256 value) internal {require(token.transfer(to,value),"SafeERC20: transfer failed");}
    function safeTransferFrom(IERC20 token,address from,address to,uint256 value) internal {require(token.transferFrom(from,to,value),"SafeERC20: transferFrom failed");}
}

/* === END OpenZeppelin Essentials === */

/* === BEGIN ZARU Advanced Contract === */
contract ZARU is ERC20, ERC20Burnable, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public immutable maxSupply;
    address public nftContract;

    string public website;
    string public twitter;
    string public telegram;

    mapping(address=>bool) public airdropped;
    mapping(uint256=>bool) public claimedNFT;
    mapping(uint256=>bool) public rewardedNFTs;

    mapping(address=>uint256) public staked;
    mapping(address=>uint256) public stakeTimestamp;
    uint256 public rewardRate = 10; // %APR

    IERC20 public lpToken;
    mapping(address=>uint256) public lpStaked;
    mapping(address=>uint256) public lpStakeTimestamp;
    uint256 public lpRewardRate = 10; // %APR

    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
    }
    Proposal[] public proposals;
    mapping(uint256=>mapping(address=>bool)) public voted;

    event Airdropped(address indexed recipient,uint256 amount);
    event NFTClaimed(address indexed user,uint256 tokenId,uint256 amount);
    event LinksUpdated(string website,string twitter,string telegram);
    event Staked(address indexed user,uint256 amount);
    event Unstaked(address indexed user,uint256 amount,uint256 reward);
    event LPStaked(address indexed user,uint256 amount);
    event LPUnstaked(address indexed user,uint256 amount,uint256 zaruReward);
    event ProposalCreated(uint256 id,string description);
    event ProposalExecuted(uint256 id);
    event RewardRatesUpdated(uint256 zaruAPR,uint256 lpAPR);
    event LPTokenSet(address lpToken);

    constructor() ERC20("ZARU","ZARU") {
        uint256 initial = 100_000_000 * 10**decimals();
        maxSupply = 1_000_000_000 * 10**decimals();
        _mint(msg.sender, initial);
        transferOwnership(msg.sender);

        website = "https://ZARUverse.com";
        twitter = "https://twitter.com/ZARUverse";
        telegram = "https://t.me/ZARUverse";
    }

    /* === Admin functions === */
    function updateLinks(string calldata _website,string calldata _twitter,string calldata _telegram) external onlyOwner {
        website = _website; twitter = _twitter; telegram = _telegram;
        emit LinksUpdated(_website,_twitter,_telegram);
    }

    function setRewardRate(uint256 newRate) external onlyOwner {
        require(newRate <= 1000,"APR too high");
        rewardRate = newRate;
        emit RewardRatesUpdated(rewardRate, lpRewardRate);
    }

    function setLPRewardRate(uint256 newRate) external onlyOwner {
        require(newRate <= 1000,"APR too high");
        lpRewardRate = newRate;
        emit RewardRatesUpdated(rewardRate, lpRewardRate);
    }

    function setLPToken(address _lpToken) external onlyOwner {
        require(_lpToken != address(0),"LP zero address");
        lpToken = IERC20(_lpToken);
        emit LPTokenSet(_lpToken);
    }

    function mint(address to,uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= maxSupply,"Exceeds max supply");
        _mint(to,amount);
    }

    function airdrop(address[] calldata recipients,uint256 amount) external onlyOwner {
        uint256 total = amount * recipients.length;
        require(totalSupply() + total <= maxSupply,"Exceeds max supply");
        for(uint256 i=0;i<recipients.length;i++){
            require(!airdropped[recipients[i]],"Already airdropped");
            airdropped[recipients[i]] = true;
            _mint(recipients[i], amount);
            emit Airdropped(recipients[i], amount);
        }
    }

    function setNFTContract(address _nftContract) external onlyOwner {
        nftContract = _nftContract;
    }

    function claimWithNFT(uint256 tokenId,uint256 amount) external {
        require(nftContract != address(0),"NFT not set");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender,"Not owner");
        require(!claimedNFT[tokenId],"Already claimed");
        require(totalSupply() + amount <= maxSupply,"Exceeds max supply");

        claimedNFT[tokenId] = true;
        _mint(msg.sender, amount);
        emit NFTClaimed(msg.sender, tokenId, amount);
    }

    function rewardNFT(uint256 tokenId,uint256 amount) external onlyOwner {
        require(nftContract != address(0),"NFT not set");
        require(!rewardedNFTs[tokenId],"Already rewarded");
        require(totalSupply() + amount <= maxSupply,"Exceeds max supply");
        address ownerAddr = IERC721(nftContract).ownerOf(tokenId);
        rewardedNFTs[tokenId] = true;
        _mint(ownerAddr, amount);
        emit NFTClaimed(ownerAddr, tokenId, amount);
    }

    /* === ZARU Staking === */
    function stake(uint256 amount) external {
        require(amount > 0,"Amount zero");
        _transfer(msg.sender,address(this),amount);
        staked[msg.sender] += amount;
        stakeTimestamp[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }

    function unstake() external nonReentrant {
        uint256 principal = staked[msg.sender];
        require(principal > 0,"No stake");
        uint256 duration = block.timestamp - stakeTimestamp[msg.sender];
        uint256 reward = (principal * rewardRate * duration) / (365 days * 100);

        staked[msg.sender] = 0;
        stakeTimestamp[msg.sender] = 0;

        _transfer(address(this), msg.sender, principal);
        if(reward > 0){
            require(totalSupply() + reward <= maxSupply,"Exceeds max supply");
            _mint(msg.sender, reward);
        }
        emit Unstaked(msg.sender, principal, reward);
    }

    /* === LP Staking === */
    function stakeLP(uint256 amount) external {
        require(address(lpToken) != address(0),"LP not set");
        require(amount > 0,"Amount zero");
        lpToken.safeTransferFrom(msg.sender,address(this),amount);
        lpStaked[msg.sender] += amount;
        lpStakeTimestamp[msg.sender] = block.timestamp;
        emit LPStaked(msg.sender, amount);
    }

    function unstakeLP() external nonReentrant {
        require(address(lpToken) != address(0),"LP not set");
        uint256 principal = lpStaked[msg.sender];
        require(principal > 0,"No LP stake");
        uint256 duration = block.timestamp - lpStakeTimestamp[msg.sender];
        uint256 zaruReward = (principal * lpRewardRate * duration) / (365 days * 100);

        lpStaked[msg.sender] = 0;
        lpStakeTimestamp[msg.sender] = 0;

        lpToken.safeTransfer(msg.sender, principal);
        if(zaruReward > 0){
            require(totalSupply() + zaruReward <= maxSupply,"Exceeds max supply");
            _mint(msg.sender, zaruReward);
        }
        emit LPUnstaked(msg.sender, principal, zaruReward);
    }

    /* === Proposal & Vote === */
    function createProposal(string calldata desc) external onlyOwner {
        proposals.push(Proposal(desc,0,false));
        emit ProposalCreated(proposals.length-1,desc);
    }

    function voteOnProposal(uint256 proposalId) external {
        require(proposalId < proposals.length,"Invalid proposal");
        require(balanceOf(msg.sender) > 0,"No tokens");
        require(!voted[proposalId][msg.sender],"Already voted");

        proposals[proposalId].voteCount += balanceOf(msg.sender);
        voted[proposalId][msg.sender] = true;
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < proposals.length,"Invalid proposal");
        Proposal storage p = proposals[proposalId];
        require(!p.executed,"Already executed");
        p.executed = true;
        emit ProposalExecuted(proposalId);
    }
}
