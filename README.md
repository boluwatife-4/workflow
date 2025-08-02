# WorkFlow - Next-Generation Decentralized Freelance Platform

![Stacks](https://img.shields.io/badge/Stacks-v3.1-orange)
![Clarity](https://img.shields.io/badge/Clarity-v3-blue)
![License](https://img.shields.io/badge/License-ISC-green)
![Tests](https://img.shields.io/badge/Tests-Vitest-yellow)

## 🌟 Overview

WorkFlow transforms the gig economy by creating a transparent, secure, and decentralized marketplace where talent meets opportunity without intermediaries. Built on the Stacks blockchain with Bitcoin-level security guarantees, WorkFlow empowers the future of work through smart contract automation and community governance.

### Key Features

- **🔒 Smart Contract Escrow**: Automated payment security with milestone-driven releases
- **⚖️ Community Governance**: Decentralized dispute resolution mechanism
- **📊 Immutable Reputation**: Transparent rating system building long-term trust
- **💸 Zero-Fee Transactions**: Direct STX transfers between parties
- **🔍 Complete Transparency**: Open bidding process with full project visibility
- **⚡ High Performance**: Leveraging Stacks Layer 2 for optimal throughput

## 🏗️ Architecture

WorkFlow leverages the Stacks blockchain architecture to provide:

- **Bitcoin Security**: Inherits Bitcoin's immutability and security
- **Layer 2 Performance**: High throughput smart contract execution
- **Clarity Language**: Predictable and secure smart contract logic
- **Permanent Record**: All transactions recorded on-chain

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) >= 2.0.0
- [Node.js](https://nodejs.org/) >= 18.0.0
- [Stacks CLI](https://docs.stacks.co/tools/cli) (optional)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/boluwatife-4/workflow.git
   cd workflow
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify installation**

   ```bash
   clarinet check
   ```

### Development Setup

1. **Start local development environment**

   ```bash
   clarinet console
   ```

2. **Run tests**

   ```bash
   npm test
   ```

3. **Run tests with coverage**

   ```bash
   npm run test:report
   ```

4. **Watch mode for development**

   ```bash
   npm run test:watch
   ```

## 📋 Contract Interface

### Core Functions

#### Job Management

- **`post-job`** - Create new job posting with escrow funding
- **`place-bid`** - Submit proposal for available projects
- **`accept-bid`** - Award project to selected freelancer
- **`complete-milestone`** - Release milestone payments

#### Dispute Resolution

- **`raise-dispute`** - Initiate community arbitration
- **`vote-on-dispute`** - Community voting on disputes

#### Reputation System

- **`rate-user`** - Submit user ratings after completion

### Read-Only Functions

- **`get-job-details`** - Retrieve complete job information
- **`get-user-rating`** - Access user reputation data
- **`get-bid`** - Fetch specific bid details
- **`get-job-bidders`** - List all bidders for a job
- **`get-dispute-details`** - Access dispute information
- **`get-escrow-status`** - Check escrow status

## 🔧 Configuration

### Constants

```clarity
MIN-BUDGET: 1 STX minimum
MAX-BUDGET: 100,000 STX maximum
MAX-BIDDERS: 100 per job
MAX-MILESTONES: 10 per project
MAX-DAILY-JOBS: 10 per user
MAX-DAILY-BIDS: 50 per user
```

### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ERR-NOT-AUTHORIZED | Insufficient permissions |
| u101 | ERR-INVALID-JOB | Job not found or invalid |
| u102 | ERR-INVALID-STATUS | Invalid status transition |
| u103 | ERR-INSUFFICIENT-FUNDS | Insufficient balance |
| u104 | ERR-ALREADY-BIDDED | User already placed bid |
| u105 | ERR-DISPUTE-EXISTS | Dispute already active |
| u106 | ERR-INVALID-RATING | Rating out of range |
| u107 | ERR-TOO-MANY-BIDDERS | Maximum bidders exceeded |
| u108 | ERR-INVALID-INPUT | Input validation failed |
| u109 | ERR-MILESTONE-OUT-OF-BOUNDS | Invalid milestone index |
| u110 | ERR-INVALID-MILESTONES | Milestone validation failed |
| u111 | ERR-RATE-LIMITED | Rate limit exceeded |

## 🧪 Testing

The project includes comprehensive test coverage using Vitest and Clarinet SDK.

### Running Tests

```bash
# Run all tests
npm test

# Run with coverage and cost analysis
npm run test:report

# Watch mode during development
npm run test:watch

# Check contracts only
clarinet check
```

### Test Structure

```
tests/
├── workflow.test.ts          # Main contract tests
└── helpers/                  # Test utilities
```

## 📊 Usage Examples

### Creating a Job

```clarity
(contract-call? .workflow post-job
  "Build a DeFi Dashboard"
  "Create a modern dashboard for DeFi protocols with real-time data"
  u5000000  ;; 5 STX budget
  (list u2000000 u2000000 u1000000)  ;; 3 milestones
)
```

### Placing a Bid

```clarity
(contract-call? .workflow place-bid
  u1  ;; job-id
  u4500000  ;; bid amount
  "I have 5 years experience in DeFi development..."
)
```

### Accepting a Bid

```clarity
(contract-call? .workflow accept-bid
  u1  ;; job-id
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; freelancer
)
```

## 🔐 Security Features

### Input Validation

- Comprehensive string length validation
- Numeric bounds checking
- Milestone structure validation
- Rate limiting protection

### Access Control

- Role-based permissions
- Job participant verification
- Dispute voting restrictions

### Economic Security

- Escrow-backed payments
- Milestone-driven releases
- Community dispute resolution

## 🌐 Deployment

### Testnet Deployment

1. **Configure network**

   ```bash
   clarinet deployments generate --devnet
   ```

2. **Deploy contracts**

   ```bash
   clarinet deployments apply --devnet
   ```

### Mainnet Deployment

1. **Prepare deployment plan**

   ```bash
   clarinet deployments generate --mainnet
   ```

2. **Execute deployment**

   ```bash
   clarinet deployments apply --mainnet
   ```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### Code Standards

- Follow Clarity best practices
- Maintain comprehensive test coverage
- Document all public functions
- Use meaningful variable names

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Explorer**: [explorer.stacks.co](https://explorer.stacks.co)
- **Stacks**: [stacks.co](https://stacks.co)
- **Clarity**: [clarity-lang.org](https://clarity-lang.org)

## 🏆 Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Clarity language team for smart contract capabilities
- Open source community for continuous support

---

Built with ❤️ on Stacks blockchain
