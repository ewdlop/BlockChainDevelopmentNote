// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EmployeePayroll {
    // Struct to store employee details
    struct Employee {
        address payable wallet; // Employee's wallet address
        uint256 salary;         // Salary in wei (1 ETH = 10^18 wei)
        bool isActive;          // Active status
    }

    // Mapping to store employees by their unique ID
    mapping(uint256 => Employee) public employees;

    // Owner of the contract (e.g., government admin)
    address public owner;

    // Events
    event EmployeeAdded(uint256 indexed employeeId, address wallet, uint256 salary);
    event SalaryPaid(uint256 indexed employeeId, address wallet, uint256 amount);
    event EmployeeRemoved(uint256 indexed employeeId, address wallet);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender; // Set the deployer as the owner
    }

    // Add a new employee
    function addEmployee(uint256 employeeId, address payable wallet, uint256 salary) external onlyOwner {
        require(employees[employeeId].wallet == address(0), "Employee already exists");
        require(wallet != address(0), "Invalid wallet address");
        require(salary > 0, "Salary must be greater than 0");

        employees[employeeId] = Employee(wallet, salary, true);
        emit EmployeeAdded(employeeId, wallet, salary);
    }

    // Remove an employee
    function removeEmployee(uint256 employeeId) external onlyOwner {
        require(employees[employeeId].wallet != address(0), "Employee does not exist");
        require(employees[employeeId].isActive, "Employee already inactive");

        employees[employeeId].isActive = false;
        emit EmployeeRemoved(employeeId, employees[employeeId].wallet);
    }

    // Pay salary to an employee
    function paySalary(uint256 employeeId) external onlyOwner {
        Employee memory employee = employees[employeeId];
        require(employee.wallet != address(0), "Employee does not exist");
        require(employee.isActive, "Employee is not active");
        require(address(this).balance >= employee.salary, "Insufficient contract balance");

        employee.wallet.transfer(employee.salary);
        emit SalaryPaid(employeeId, employee.wallet, employee.salary);
    }

    // Allow the contract owner to deposit ETH
    function depositFunds() external payable onlyOwner {}

    // View contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
