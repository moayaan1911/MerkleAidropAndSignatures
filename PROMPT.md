Create an interactive, single-page HTML documentation file called "ProjectExplanation.html" for this project. The file should be educational, visually appealing, and easy to understand for both beginners and experienced developers.

## REQUIREMENTS:

### 1. STRUCTURE (5 Sections Total):

**Section 1: Logic Flow & Visuals**
- System architecture diagram using Mermaid.js
- Show the complete flow from off-chain to on-chain
- Include TWO explanation cards side-by-side:
  - **Normal Explanation**: Technical but accessible explanation
  - **ELI5 Explanation**: Use simple analogies, NO technical jargon (explain like I'm 5 years old)

**Section 2: Files Deep Dive**
- For EACH main contract file:
  - Header with file name and purpose badge
  - Purpose section explaining what the file does
  - Key Components section (state variables, constructor, etc.)
  - Main functions with code snippets
  - **IMPORTANT**: Explanations must be OUTSIDE the code blocks, not inside
  - Use color-coded cards with step-by-step breakdowns
  - Include visual hierarchy with proper spacing

**Section 3: [CUSTOM CONCEPT 1]**
- Pick the FIRST most important technical concept in the project
- Explain it thoroughly with:
  - Visual diagrams (SVG or Mermaid)
  - Normal explanation (technical)
  - ELI5 explanation (use real-world analogies, no technical terms)
- Examples: Digital Signatures, Oracles, Flash Loans, Governance, etc.

**Section 4: [CUSTOM CONCEPT 2]**
- Pick the SECOND most important technical concept
- Same format as Section 3
- Should complement Section 3 (cover different aspects)
- Examples: Merkle Trees, EIP-712, Proxy Patterns, AMM Math, etc.

**Section 5: Foundry/Hardhat Workflow**
- Step-by-step guide through ALL scripts
- For EACH script:
  - Purpose explanation
  - Detailed step-by-step breakdown (what it does internally)
  - How to run it (actual command)
  - Output file structure (if applicable)
  - Gas costs (if on-chain)
- Include a summary card at the end showing the complete workflow

### 2. DESIGN REQUIREMENTS:

**Technology Stack:**
- Use Tailwind CSS (via CDN)
- Use Mermaid.js for diagrams (via CDN)
- Single HTML file (no external dependencies except CDNs)
- Responsive design (mobile-friendly)

**Visual Style:**
- Modern, clean design with card-based layout
- Color-coded sections (blue, purple, pink, green, orange, etc.)
- Gradient backgrounds for important sections
- Custom scrollbar styling
- Smooth animations and transitions
- Icons/emojis for visual appeal

**Navigation:**
- Sidebar navigation with 5 sections
- Active state highlighting
- Smooth scrolling between sections
- Section numbers (1-5)

**Code Blocks:**
- Dark theme (slate-900 background)
- Syntax highlighting with color classes (.k for keywords, .t for types, .f for functions, .s for strings, .c for comments, .v for variables)
- Code header with file path
- Small, readable font size

**Explanation Cards:**
- Always provide BOTH Normal and ELI5 explanations
- ELI5 must use simple analogies (no technical terms like "hashing", "cryptographic", "algorithm")
- Use real-world comparisons: parties, tickets, stamps, handshakes, LEGO, books, etc.
- Color-coded borders (left border accent)

### 3. CONTENT GUIDELINES:

**ELI5 Rules (CRITICAL):**
- Explain like the reader is 5 years old
- NO technical jargon: avoid words like "hash", "cryptographic", "algorithm", "protocol", "consensus"
- Use physical analogies: stamps, tickets, handshakes, toys, books, folders
- Use action words: "squish", "fold", "glue", "check", "match"
- Keep sentences short and simple

**Code Explanation Rules:**
- Code snippets should be concise (10-20 lines max)
- Full explanations go OUTSIDE the code block
- Use step-by-step numbered breakdowns
- Include "Why?" explanations, not just "What?"

**Visual Diagrams:**
- Use Mermaid for flow diagrams
- Use SVG for technical visualizations (curves, trees, etc.)
- Include labels and legends
- Use color to show relationships

### 4. SPECIFIC INSTRUCTIONS FOR THIS PROJECT:

**Scan the project and identify:**
1. Main contract files (in src/ or contracts/)
2. Script files (deployment, interaction, setup)
3. The two most important technical concepts to explain
4. The workflow from setup to execution

**Then create the HTML with:**
- Section 1: Overall system flow
- Section 2: Deep dive into each main contract
- Section 3 & 4: The two key concepts you identified
- Section 5: Complete script workflow

### 5. TEMPLATE STRUCTURE:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Project Name] Explorer</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
        import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
        mermaid.initialize({ startOnLoad: true, theme: 'neutral', securityLevel: 'loose' });
    </script>
    <style>
        /* Include custom styles for cards, code blocks, navigation, etc. */
    </style>
</head>
<body class="h-screen flex flex-col md:flex-row overflow-hidden bg-slate-50">
    <!-- SIDEBAR NAVIGATION -->
    <aside class="w-full md:w-80 bg-white border-r border-slate-200 flex flex-col z-20 shadow-xl">
        <!-- 5 navigation items -->
    </aside>

    <!-- MAIN CONTENT AREA -->
    <main class="flex-1 overflow-y-auto bg-slate-50/50 p-6 md:p-12 relative scroll-smooth">
        <!-- 5 sections with hidden-section class (except first) -->
    </main>

    <script>
        function showSection(id) {
            // Toggle section visibility
        }
    </script>
</body>
</html>
```

### 6. QUALITY CHECKLIST:

Before finalizing, ensure:
- [ ] All 5 sections are present and complete
- [ ] ELI5 explanations use NO technical jargon
- [ ] Code explanations are OUTSIDE code blocks
- [ ] Visual diagrams are clear and labeled
- [ ] Navigation works smoothly
- [ ] Mobile responsive
- [ ] Color scheme is consistent
- [ ] Step-by-step workflow is detailed
- [ ] Both Normal and ELI5 for key concepts
- [ ] File is self-contained (no external files except CDNs)

## OUTPUT:

Generate the complete HTML file with all sections filled out based on the project's actual code and structure. Make it educational, beautiful, and comprehensive!
```
