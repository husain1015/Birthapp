# AI Exercise Recommendations Setup

## Overview
The ReadyBirth Prep app now includes AI-powered exercise recommendations using Claude. The system analyzes:
- Current week of pregnancy
- Exercise history from the past 7 days
- Fitness level
- Days until due date

## Setup Instructions

### 1. Get Your Anthropic API Key
1. Go to https://console.anthropic.com/
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key

### 2. Add API Key to Xcode
1. In Xcode, select your project target
2. Go to the "Info" tab
3. Under "Custom iOS Target Properties", add a new entry:
   - Key: `ANTHROPIC_API_KEY`
   - Type: String
   - Value: Your API key

**Alternative: Environment Variable**
1. Edit your scheme (Product → Scheme → Edit Scheme)
2. Select "Run" on the left
3. Go to the "Arguments" tab
4. Add an environment variable:
   - Name: `ANTHROPIC_API_KEY`
   - Value: Your API key

### 3. Security Note
⚠️ **IMPORTANT**: Never commit your API key to version control!
- Add `*.xcconfig` to your `.gitignore` if using configuration files
- Consider using a secrets management system for production

## Features

### Daily AI Recommendations
- Personalized exercise suggestions based on pregnancy week
- Considers exercise history to avoid repetition
- Provides reasoning for each recommendation
- Includes safety notes specific to your trimester

### Exercise Tracking
- Automatically tracks completed exercises
- Stores duration and completion time
- Used by AI to vary future recommendations

### Smart Recommendations Consider:
1. **Pregnancy Stage**: Different exercises for each trimester
2. **Recent Activity**: Avoids repeating same exercises
3. **Fitness Level**: Adjusts intensity based on your profile
4. **Labor Preparation**: Focuses on relevant exercises as due date approaches

## How It Works

1. **Daily Generation**: Recommendations are generated once per day
2. **Caching**: Results are cached to reduce API calls
3. **History Analysis**: Last 7 days of exercises are analyzed
4. **Personalization**: Each recommendation includes:
   - 3-4 exercises
   - Reasoning for selection
   - Focus areas
   - Safety notes

## Troubleshooting

### No Recommendations Showing
- Check API key is properly set
- Verify internet connection
- Check Xcode console for error messages

### API Errors
- Ensure API key has sufficient credits
- Check rate limits on your Anthropic account
- Verify API key permissions

## Cost Considerations
- Each recommendation uses approximately 500-1000 tokens
- With Claude 3.5 Sonnet: ~$0.003 per recommendation
- Daily use for one user: ~$0.10/month

## Future Enhancements
- Voice guidance integration
- Progress analytics
- Community recommendations
- Partner exercise suggestions