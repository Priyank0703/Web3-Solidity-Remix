// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Twitter {
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 createdAt;
    }
    
    struct Message {
        uint256 id;
        string content;
        address from;
        address to;
        uint256 createdAt;
    }
    
    uint256 private nextTweetId = 1;
    uint256 private nextMessageId = 1;
    
    mapping(uint256 => Tweet) public tweets;
    mapping(address => uint256[]) public tweetsOf;
    mapping(address => mapping(address => Message[])) public conversations;
    mapping(address => mapping(address => bool)) public operators;
    mapping(address => address[]) public following;
    
    event TweetCreated(uint256 indexed tweetId, address indexed author, string content, uint256 createdAt);
    event MessageSent(uint256 indexed messageId, address indexed from, address indexed to, string content, uint256 createdAt);
    event UserFollowed(address indexed follower, address indexed followed);
    event OperatorAllowed(address indexed owner, address indexed operator);
    event OperatorDisallowed(address indexed owner, address indexed operator);
    
    modifier onlyOperatorOrOwner(address _owner) {
        require(
            msg.sender == _owner || operators[_owner][msg.sender],
            "Not authorized to act on behalf of this user"
        );
        _;
    }
    
    function _tweet(address _from, string memory _content) internal {
        require(bytes(_content).length > 0, "Tweet content cannot be empty");
        require(bytes(_content).length <= 280, "Tweet content too long");
        
        uint256 tweetId = nextTweetId++;
        
        tweets[tweetId] = Tweet({
            id: tweetId,
            author: _from,
            content: _content,
            createdAt: block.timestamp
        });
        
        tweetsOf[_from].push(tweetId);
        
        emit TweetCreated(tweetId, _from, _content, block.timestamp);
    }
    
    function _sendMessage(address _from, address _to, string memory _content) internal {
        require(_to != address(0), "Cannot send message to zero address");
        require(bytes(_content).length > 0, "Message content cannot be empty");
        require(_from != _to, "Cannot send message to yourself");
        
        uint256 messageId = nextMessageId++;
        
        Message memory newMessage = Message({
            id: messageId,
            content: _content,
            from: _from,
            to: _to,
            createdAt: block.timestamp
        });
        
        conversations[_from][_to].push(newMessage);
        conversations[_to][_from].push(newMessage);
        
        emit MessageSent(messageId, _from, _to, _content, block.timestamp);
    }
    
    function tweet(string memory _content) public {
        _tweet(msg.sender, _content);
    }
    
    function tweet(address _from, string memory _content) public onlyOperatorOrOwner(_from) {
        _tweet(_from, _content);
    }
    
    function sendMessage(string memory _content, address _to) public {
        _sendMessage(msg.sender, _to, _content);
    }
    
    function sendMessage(address _from, address _to, string memory _content) public onlyOperatorOrOwner(_from) {
        _sendMessage(_from, _to, _content);
    }
    
    function follow(address _followed) public {
        require(_followed != address(0), "Cannot follow zero address");
        require(_followed != msg.sender, "Cannot follow yourself");
        
        for (uint i = 0; i < following[msg.sender].length; i++) {
            if (following[msg.sender][i] == _followed) {
                revert("Already following this user");
            }
        }
        
        following[msg.sender].push(_followed);
        emit UserFollowed(msg.sender, _followed);
    }
    
    function allow(address _operator) public {
        require(_operator != address(0), "Cannot set zero address as operator");
        require(_operator != msg.sender, "Cannot set yourself as operator");
        require(!operators[msg.sender][_operator], "Operator already allowed");
        
        operators[msg.sender][_operator] = true;
        emit OperatorAllowed(msg.sender, _operator);
    }
    
    function disallow(address _operator) public {
        require(operators[msg.sender][_operator], "Operator not currently allowed");
        
        operators[msg.sender][_operator] = false;
        emit OperatorDisallowed(msg.sender, _operator);
    }
    
    function getLatestTweets(uint count) public view returns (Tweet[] memory) {
        require(count > 0, "Count must be greater than 0");
        
        uint256 totalTweets = nextTweetId - 1;
        uint256 resultCount = count > totalTweets ? totalTweets : count;
        
        Tweet[] memory result = new Tweet[](resultCount);
        
        for (uint256 i = 0; i < resultCount; i++) {
            result[i] = tweets[totalTweets - i];
        }
        
        return result;
    }
    
    function getLatestTweetsOf(address user, uint count) public view returns (Tweet[] memory) {
        require(user != address(0), "Invalid user address");
        require(count > 0, "Count must be greater than 0");
        
        uint256[] memory userTweetIds = tweetsOf[user];
        uint256 userTweetCount = userTweetIds.length;
        uint256 resultCount = count > userTweetCount ? userTweetCount : count;
        
        Tweet[] memory result = new Tweet[](resultCount);
        
        for (uint256 i = 0; i < resultCount; i++) {
            uint256 tweetId = userTweetIds[userTweetCount - 1 - i];
            result[i] = tweets[tweetId];
        }
        
        return result;
    }
    
    function getTotalTweets() public view returns (uint256) {
        return nextTweetId - 1;
    }
    
    function getTweetCount(address user) public view returns (uint256) {
        return tweetsOf[user].length;
    }
    
    function getFollowing(address user) public view returns (address[] memory) {
        return following[user];
    }
    
    function getFollowingCount(address user) public view returns (uint256) {
        return following[user].length;
    }
    
    function isOperator(address owner, address operator) public view returns (bool) {
        return operators[owner][operator];
    }
    
    function getConversation(address user1, address user2) public view returns (Message[] memory) {
        return conversations[user1][user2];
    }
    
    function isFollowing(address follower, address followed) public view returns (bool) {
        for (uint i = 0; i < following[follower].length; i++) {
            if (following[follower][i] == followed) {
                return true;
            }
        }
        return false;
    }
}