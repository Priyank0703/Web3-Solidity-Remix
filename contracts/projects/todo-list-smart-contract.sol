// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {
    uint public taskCount;
    
    struct Task {
        uint id;
        string content;
        bool completed;
    }
    
    mapping(uint => Task) public tasks;
    
    event TaskCreated(uint indexed id, string content);
    event TaskCompleted(uint indexed id, bool completed);
    
    constructor() {
        taskCount = 0;
        createTask("Initial Task");
    }
    
    function createTask(string memory _content) public {
        taskCount++;
        
        tasks[taskCount] = Task({
            id: taskCount,
            content: _content,
            completed: false
        });
        
        emit TaskCreated(taskCount, _content);
    }
    
    function toggleTaskCompleted(uint _id) public {
        require(_id > 0 && _id <= taskCount, "Task does not exist");
        
        Task storage task = tasks[_id];
        task.completed = !task.completed;
        
        emit TaskCompleted(_id, task.completed);
    }
    
    function getTask(uint _id) public view returns (uint, string memory, bool) {
        require(_id > 0 && _id <= taskCount, "Task does not exist");
        
        Task memory task = tasks[_id];
        return (task.id, task.content, task.completed);
    }
    
    function getTaskCount() public view returns (uint) {
        return taskCount;
    }
    
    function getAllTasks() public view returns (Task[] memory) {
        Task[] memory allTasks = new Task[](taskCount);
        
        for (uint i = 1; i <= taskCount; i++) {
            allTasks[i - 1] = tasks[i];
        }
        
        return allTasks;
    }
}