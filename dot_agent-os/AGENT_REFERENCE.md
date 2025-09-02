# Agent Quick Reference Guide

## 🤖 When to Use Each Agent

This guide helps you quickly identify which specialized agent to use for maximum leverage in your development workflow.

### 🟣 OTP Architect (`otp-architect`)
**Use when you see these keywords or tasks:**
- GenServer, Supervisor, Agent, Task
- Process design, concurrent systems
- Fault tolerance, supervision trees
- Registry patterns, dynamic supervision
- Performance optimization for BEAM
- Distributed system challenges

**File patterns that trigger:**
- `**/gen_server.ex`, `**/supervisor.ex`, `**/application.ex`
- Any file containing OTP behavior modules

**Example triggers:**
- "How should I structure my GenServer?"
- "I need to design a supervision tree"
- "My processes are crashing unexpectedly"
- "How do I handle distributed state?"

### 🟠 DevOps Engineer (`devops-engineer`) 
**Use when you see these keywords or tasks:**
- Deploy, deployment, CI/CD, infrastructure
- Docker, containers, Fly.io
- GitHub Actions, releases, monitoring
- Production issues, scaling

**File patterns that trigger:**
- `fly.toml`, `Dockerfile*`, `.github/workflows/**`
- `docker-compose.yml`, release configurations

**Example triggers:**
- "My deployment is failing"
- "Set up CI/CD pipeline"
- "Production performance issues"
- "Need monitoring and alerting"

### 🔴 DevSecOps Engineer (`devsecops-engineer`)
**Use when you see these keywords or tasks:**
- Security, auth, authorization, authentication
- Vulnerability, compliance, encryption
- CSRF, XSS, SSL, data protection
- Audits, penetration testing

**File patterns that trigger:**
- `**/auth*.ex`, `**/security*.ex`, `**/plugs/**`
- Configuration files with security settings

**Example triggers:**
- "Review my authentication system"
- "Need security audit"
- "Compliance requirements (SOC2, GDPR)"
- "Vulnerability in dependencies"

### 🟢 Testing Specialist (`testing-specialist`)
**Use when you see these keywords or tasks:**
- Test, testing, ExUnit, spec, assert
- Mock, Wallaby, property testing
- Coverage, integration tests, debugging
- Quality assurance, test strategy

**File patterns that trigger:**
- `test/**/*.exs`, `*_test.exs`, `test_helper.exs`
- Any file in test directories

**Example triggers:**
- "How should I test this GenServer?"
- "Need comprehensive test coverage"
- "Flaky tests in CI"
- "Set up end-to-end testing"

### 🩷 UX Designer (`ux-designer`)
**Use when you see these keywords or tasks:**
- UI, UX, design, interface
- User experience, accessibility
- Templates, CSS, HTML, responsive
- Usability, user research

**File patterns that trigger:**
- `lib/**/*.eex`, `lib/**/*.heex`
- `assets/**/*.css`, `priv/static/**`

**Example triggers:**
- "This interface feels clunky"
- "Need accessibility improvements"
- "User feedback about confusing flow"
- "Design system consistency"

## 🔄 Collaboration Patterns

### Multi-Agent Workflows
These scenarios benefit from using multiple agents in sequence:

1. **Architecture → Testing**
   - Use `otp-architect` for GenServer design
   - Then `testing-specialist` for comprehensive test coverage

2. **Security → Deployment**
   - Use `devsecops-engineer` for security review
   - Then `devops-engineer` for secure deployment

3. **Design → Testing**
   - Use `ux-designer` for interface improvements
   - Then `testing-specialist` for user acceptance testing

4. **Architecture → Performance**
   - Use `otp-architect` for system design
   - Then `devops-engineer` for production optimization

## 🎯 Maximizing Agent Leverage

### Before Starting Any Task, Ask:
1. **What domain does this task belong to?**
   - OTP/Concurrency → `otp-architect`
   - Infrastructure/Deployment → `devops-engineer`  
   - Security → `devsecops-engineer`
   - Quality/Testing → `testing-specialist`
   - User Interface → `ux-designer`

2. **What files am I working with?**
   - Check the file patterns above for automatic suggestions

3. **What keywords are in my task description?**
   - Match keywords to the agent specializations

4. **Would this benefit from specialized expertise?**
   - If yes, use the specialist agent
   - If it spans multiple domains, plan a multi-agent approach

### Context to Always Provide:
- Current project state and goals
- Specific technical constraints
- Error messages or logs (when debugging)
- User feedback or metrics (when available)
- Target environment (dev/staging/production)
- Timeline and priority considerations

### Red Flags for Agent Usage:
- **DON'T** use agents for trivial tasks that don't need specialized expertise
- **DO** use agents for any task that could benefit from domain-specific best practices
- **DON'T** forget to provide comprehensive context (agents have no conversation history)
- **DO** consider multi-agent workflows for complex cross-domain tasks

## 🚀 Pro Tips

1. **Start with the most specialized agent** for your primary concern
2. **Chain agents** for comprehensive solutions across domains
3. **Use file patterns** as automatic triggers for agent selection
4. **Provide rich context** - agents work better with more information
5. **Think beyond code** - use UX designer for any interface improvements
6. **Security first** - involve devsecops-engineer early in design phase
7. **Test continuously** - use testing-specialist throughout development, not just at the end

## 📋 Quick Checklist

Before working on any significant task:
- [ ] Identified the primary domain (OTP/DevOps/Security/Testing/UX)
- [ ] Checked file patterns for automatic agent suggestions
- [ ] Considered if multiple agents would provide better coverage
- [ ] Prepared comprehensive context and requirements
- [ ] Planned follow-up with additional agents if needed

Remember: The goal is to leverage specialized expertise for better outcomes, not to use agents for every simple task. Use them strategically for maximum impact!
