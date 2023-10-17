# Reinforcement Learning Models Application

We applied single-process reinforcement learning models (Sutton & Barto, 1998) to better understand patterns of participants’ choices and the underlying motivations. The models discerned between participants who based their choice probabilities on the expected required cognitive effort of the options and those who based them on choice lags, indicating the number of trials since an option was last chosen.

Choice lag is indicative of internal uncertainty; our memory weakens in correlation with the duration since an option was last examined. If the primary goal is to diminish uncertainty, participants would opt based on choice lag. Conversely, if the aims are optimizing cognitive performance or conserving cognitive effort, participants would likely choose the option correlating with a presumably simpler discrimination task.

## Models Description

We fitted single-process reinforcement learning models that exemplify four distinct performance behaviors:
- **Effort Saver**: Prefers the easier task.
- **Systematic Explorer**: Actively reduces uncertainty.
- **Challenge Seeker**: Prefers the more challenging task.
- **Random Explorer**: Demonstrates no discernible pattern in their choices.

The "Effort saver" and "Challenge seeker" models gain insights into the required cognitive effort by updating the expected effort for each option based on prediction error. This is captured by the equation:

\[ V_{i, t+1} = V_{i, t} + \alpha(R_{i,t} - V_{i, t}) \]

Where:
- \( V_{i, t} \) is the expected required cognitive effort for option i on trial t.
- \( R_{i,t} \) is the actual cognitive effort required on trial t when choosing option i.
- \( \alpha \) represents the learning rate, which was set to 1 to allow direct comparison of value or lag factor influences.

Cognitive effort was defined by the dot ratio, exemplified by a comparison set of 5 dots versus 10 dots yielding a cognitive effort of 0.5. Only the chosen option's values are updated in each trial. All models initiate with \( V_i \) values set to 0.

## Choice Probabilities

Choice probabilities were ascertained by the function:

\[ P_{ai,t} = \frac{exp((V_{i,t}(1-) + L_{i,t})}{\sum_{j=1}^n exp((V_{i,t}(1-) + L_{i,t})} \]

In this equation:
- \( P_{ai,t} \) represents the likelihood of opting for option i on trial t.
- \( L_{i,t} \) is the lag term, indicating the number of trials since option i was last chosen.
- \( \delta \) determines to what extent choices are influenced by the expected required cognitive effort.

In the models:
- ‘Effort saver’ and ‘Challenge seeker’ set \( \delta \) to 0.
- ‘Systematic explorer’ has \( \delta \) set to 1.
- For the ‘Random explorer’, choice probabilities are equal, and only a noise parameter is adjusted.
