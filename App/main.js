// main.js (Electron main process)
const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const { ethers } = require('ethers');
const Web3 = require('web3');
const IPFS = require('ipfs-http-client');

let mainWindow;

async function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    mainWindow.loadFile('index.html');
}

app.whenReady().then(createWindow);

// App.js (React frontend)
import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { create } from 'ipfs-http-client';
import { Buffer } from 'buffer';

const App = () => {
    const [contract, setContract] = useState(null);
    const [account, setAccount] = useState(null);
    const [repositories, setRepositories] = useState([]);
    const [selectedRepo, setSelectedRepo] = useState(null);
    const [commits, setCommits] = useState([]);

    useEffect(() => {
        initializeEthereum();
    }, []);

    const initializeEthereum = async () => {
        if (window.ethereum) {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contractAddress = "YOUR_CONTRACT_ADDRESS";
            const contractABI = []; // Add your contract ABI here
            
            const githubContract = new ethers.Contract(
                contractAddress,
                contractABI,
                signer
            );
            
            setContract(githubContract);
            
            const accounts = await window.ethereum.request({
                method: 'eth_requestAccounts'
            });
            setAccount(accounts[0]);
        }
    };

    const createRepository = async (name, description, isPrivate) => {
        try {
            const tx = await contract.createRepository(name, description, isPrivate);
            await tx.wait();
            // Update UI
        } catch (error) {
            console.error('Error creating repository:', error);
        }
    };

    const pushCommit = async (repoName, branch, files, message) => {
        try {
            // Initialize IPFS client
            const ipfs = create('http://localhost:5001');
            
            // Add files to IPFS
            const filesBuffer = Buffer.from(JSON.stringify(files));
            const ipfsResult = await ipfs.add(filesBuffer);
            const fileChangesHash = ipfsResult.path;
            
            // Generate commit hash
            const commitHash = ethers.utils.id(
                JSON.stringify({
                    files: fileChangesHash,
                    message,
                    timestamp: Date.now()
                })
            );
            
            const tx = await contract.pushCommit(
                repoName,
                branch,
                commitHash,
                message,
                Date.now().toString(),
                fileChangesHash
            );
            await tx.wait();
            
            // Update UI
            fetchCommits(repoName, branch);
        } catch (error) {
            console.error('Error pushing commit:', error);
        }
    };

    const fetchCommits = async (repoName, branch) => {
        try {
            const commits = await contract.getCommits(repoName, branch);
            setCommits(commits);
        } catch (error) {
            console.error('Error fetching commits:', error);
        }
    };

    return (
        <div className="app-container">
            <header>
                <h1>Decentralized GitHub</h1>
                <p>Connected Account: {account}</p>
            </header>
            
            <div className="main-content">
                <div className="sidebar">
                    <h2>Repositories</h2>
                    <button onClick={() => /* Show create repo modal */}>
                        New Repository
                    </button>
                    <ul>
                        {repositories.map(repo => (
                            <li 
                                key={repo.name}
                                onClick={() => setSelectedRepo(repo)}
                            >
                                {repo.name}
                            </li>
                        ))}
                    </ul>
                </div>
                
                <div className="content">
                    {selectedRepo && (
                        <div>
                            <h2>{selectedRepo.name}</h2>
                            <div className="commits-list">
                                {commits.map(commit => (
                                    <div key={commit.commitHash} className="commit">
                                        <h3>{commit.message}</h3>
                                        <p>Author: {commit.author}</p>
                                        <p>Time: {new Date(parseInt(commit.timestamp)).toLocaleString()}</p>
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

export default App;
