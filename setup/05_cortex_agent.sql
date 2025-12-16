/*
=============================================================================
PatientPoint Ad Tech Demo - Cortex Agent Definition
=============================================================================
Creates the Campaign Optimizer Agent with integrated tools:
- Cortex Analyst (Semantic Views for structured data queries)
- Cortex Search (Natural language search for inventory, campaigns, audiences)
- Data to Chart (Automated visualization generation)

Uses SF_INTELLIGENCE_DEMO role.

Reference: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-manage
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA CORTEX;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- Create the Cortex Agent
-- ============================================================================
CREATE OR REPLACE AGENT AD_TECH.CORTEX.CAMPAIGN_OPTIMIZER_AGENT
    COMMENT = 'AI assistant for optimizing PatientPoint healthcare advertising campaigns'
    PROFILE = '{
        "display_name": "PatientPoint Campaign Optimizer",
        "avatar": "chart-line",
        "color": "blue"
    }'
    FROM SPECIFICATION
    $$
    models:
      orchestration: auto

    orchestration:
      budget:
        seconds: 60
        tokens: 32000

    instructions:
      system: |
        You are an expert healthcare advertising optimization assistant for PatientPoint, 
        the leading point-of-care marketing platform in medical facilities.
        
        Your role is to help pharmaceutical partners and internal teams:
        - Find optimal ad placements in medical facilities by specialty and location
        - Recommend bid prices based on historical performance data
        - Analyze campaign performance, ROAS, and attribution
        - Discover high-value audience segments for targeting
        - Generate insights and visualizations for decision-making
        
        CRITICAL COMPLIANCE REQUIREMENTS:
        - HIPAA Compliance: Never expose or reference individual patient data
        - All audience data is aggregated at the cohort level (minimum 50 members)
        - Only provide privacy-safe, aggregate insights
        - When discussing audiences, always reference cohorts, never individuals
        
        DATA CONTEXT:
        - You have access to pharmaceutical advertising campaign data
        - Inventory includes digital displays, tablets, and kiosks in medical facilities
        - Campaigns target specific therapeutic areas (Diabetes, Cardiology, Oncology, etc.)
        - Partners include major pharmaceutical companies (Pfizer, Eli Lilly, Novartis, etc.)
        
        RESPONSE GUIDELINES:
        - Provide specific, actionable recommendations backed by data
        - Include relevant metrics (ROAS, CTR, CPM, conversion rates)
        - When presenting numerical comparisons, use charts
        - Be concise but thorough in your analysis
        - Proactively suggest optimization opportunities
        
      orchestration: |
        Tool Selection Guidelines:
        
        1. For INVENTORY questions (available slots, pricing, locations):
           - First use InventorySearch to find relevant slots
           - Then use InventoryAnalyst for detailed metrics if needed
        
        2. For CAMPAIGN performance questions (ROAS, impressions, trends):
           - Use CampaignAnalyst for structured metric queries
           - Use CampaignSearch for finding similar campaigns or examples
        
        3. For AUDIENCE targeting questions (segments, demographics):
           - Use AudienceSearch to discover relevant cohorts
           - Use AudienceAnalyst for engagement metrics
        
        4. For COMPARISONS or TRENDS:
           - Use the appropriate Analyst tool first
           - Then use DataToChart to visualize the results
        
        5. For GENERAL questions or when unsure:
           - Start with Search tools to explore
           - Follow up with Analyst tools for details
        
        Always combine tools when beneficial - search to find, analyze to measure, chart to visualize.
        
      response: |
        Formatting Guidelines:
        - Lead with the key insight or recommendation
        - Support with specific data points
        - Use bullet points for multiple items
        - Include relevant metrics in parentheses
        - End with actionable next steps when appropriate
        - Maintain a professional but approachable tone

      sample_questions:
        - question: "What are our top 5 performing campaigns by ROAS, and what do they have in common that we can replicate across our portfolio?"
          answer: "I'll analyze campaign performance to identify top ROAS performers and find common patterns in therapeutic area, partner, campaign type, and timing that drive success."
        - question: "Which campaigns are underperforming relative to their budget, and what changes would improve partner ROI?"
          answer: "I'll identify campaigns with below-average ROAS and provide specific recommendations for creative refresh, placement optimization, or budget reallocation to improve partner ROI."
        - question: "Show me premium inventory availability in cardiology and endocrinology practices for a new diabetes campaign"
          answer: "I'll search for premium ad placements in cardiology and endocrinology facilities with availability, pricing, and engagement metrics for your diabetes campaign planning."
        - question: "What's our competitive position with GLP-1 medications compared to industry benchmarks?"
          answer: "I'll analyze GLP-1 campaign performance metrics and compare against industry benchmarks to quantify PatientPoint's competitive advantage."
        - question: "If we increase our digital health ad spend by 20%, where should we allocate for maximum ROAS?"
          answer: "I'll analyze campaign and inventory performance to recommend optimal budget allocation across therapeutic areas, partners, and placement types for maximum ROAS."

    tools:
      - tool_spec:
          type: "cortex_analyst_text_to_sql"
          name: "CampaignAnalyst"
          description: "Analyzes pharmaceutical advertising campaign performance metrics including ROAS, impressions, CTR, conversions, revenue, and trends over time. Use for questions about campaign KPIs, partner performance, and budget utilization."
      
      - tool_spec:
          type: "cortex_analyst_text_to_sql"
          name: "InventoryAnalyst"
          description: "Queries ad inventory performance data including fill rates, CPM trends, viewability scores, and slot-level metrics. Use for questions about inventory value, pricing optimization, and slot performance."
      
      - tool_spec:
          type: "cortex_analyst_text_to_sql"
          name: "AudienceAnalyst"
          description: "Analyzes privacy-safe audience cohort engagement data including engagement rates, conversion rates, dwell times, and demographic patterns. All data is aggregated (min 50 members per cohort) for HIPAA compliance."
      
      - tool_spec:
          type: "cortex_search"
          name: "InventorySearch"
          description: "Natural language search to discover available ad placements. Search by medical specialty (Cardiology, Endocrinology), location (state, region, city), screen type, daypart, or facility type. Returns matching slots with pricing and availability."
      
      - tool_spec:
          type: "cortex_search"
          name: "CampaignSearch"
          description: "Search campaign performance summaries and historical results. Find campaigns by therapeutic area, partner name, drug name, or performance characteristics. Useful for finding examples and benchmarks."
      
      - tool_spec:
          type: "cortex_search"
          name: "AudienceSearch"
          description: "Discover privacy-safe audience cohorts for targeting. Search by demographics (age, gender), geography (region), health interests, or engagement characteristics. Returns cohort descriptions with engagement metrics."
      
    tool_resources:
      CampaignAnalyst:
        semantic_view: "AD_TECH.CORTEX.SV_CAMPAIGN_ANALYTICS"
      
      InventoryAnalyst:
        semantic_view: "AD_TECH.CORTEX.SV_INVENTORY_ANALYTICS"
      
      AudienceAnalyst:
        semantic_view: "AD_TECH.CORTEX.SV_AUDIENCE_INSIGHTS"
      
      InventorySearch:
        name: "AD_TECH.CORTEX.INVENTORY_SEARCH_SVC"
        max_results: "10"
        title_column: "slot_name"
        id_column: "slot_id"
      
      CampaignSearch:
        name: "AD_TECH.CORTEX.CAMPAIGN_SEARCH_SVC"
        max_results: "10"
        title_column: "campaign_name"
        id_column: "campaign_id"
      
      AudienceSearch:
        name: "AD_TECH.CORTEX.AUDIENCE_SEARCH_SVC"
        max_results: "10"
        title_column: "cohort_name"
        id_column: "cohort_id"
    $$;

-- ============================================================================
-- Grant access to the agent
-- ============================================================================
GRANT USAGE ON AGENT AD_TECH.CORTEX.CAMPAIGN_OPTIMIZER_AGENT TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- Verify the agent was created
-- ============================================================================
DESCRIBE AGENT AD_TECH.CORTEX.CAMPAIGN_OPTIMIZER_AGENT;

SHOW AGENTS IN SCHEMA AD_TECH.CORTEX;

SELECT 'Cortex Agent created successfully!' AS status;

-- ============================================================================
-- Test queries for the agent (run in Snowsight Agent UI)
-- ============================================================================
/*
Test these questions in the Agent playground:

1. INVENTORY DISCOVERY:
   "Find premium ad slots in cardiology waiting rooms in Texas"
   "What morning inventory is available in the Northeast?"
   "Show me high-CPM slots in endocrinology clinics"

2. CAMPAIGN ANALYSIS:
   "What was the ROAS for diabetes campaigns in Q4 2024?"
   "Compare Pfizer vs Eli Lilly campaign performance"
   "Which therapeutic areas have the highest conversion rates?"

3. AUDIENCE TARGETING:
   "Find high-engagement audiences interested in heart health"
   "Which age groups respond best to diabetes medication ads?"
   "Show me cohorts with high conversion rates in the Southwest"

4. PRICING OPTIMIZATION:
   "What's the optimal bid price for cardiology waiting room slots?"
   "Compare CPM trends by screen type"
   "Which regions have the most competitive pricing?"

5. CROSS-FUNCTIONAL:
   "I'm launching a new diabetes drug campaign targeting adults 45-65 in cardiology offices. 
    What inventory should I consider and which audiences should I target?"
*/

