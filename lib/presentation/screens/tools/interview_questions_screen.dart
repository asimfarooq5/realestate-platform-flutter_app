import 'package:flutter/material.dart';
import 'package:malkiyat_app/core/theme/app_theme.dart';

const Map<String, List<String>> _questionSets = {
  'General': [
    'Tell me about yourself.',
    'Why do you want to work here?',
    'What are your strengths and weaknesses?',
    'Where do you see yourself in five years?',
    'Why are you leaving your current job?',
  ],
  'Behavioral': [
    'Tell me about a time you handled a difficult situation.',
    'Describe a conflict with a coworker and how you resolved it.',
    'Give an example of a goal you achieved and how.',
    'Tell me about a time you failed and what you learned.',
  ],
  'Questions to Ask the Interviewer': [
    'What does success look like in this role?',
    'What are the biggest challenges facing the team right now?',
    'How would you describe the company culture?',
    'What are the next steps in the hiring process?',
  ],
};

/// A general interview-prep reference — useful for anyone job hunting,
/// not tied to real estate specifically.
class InterviewQuestionsScreen extends StatelessWidget {
  const InterviewQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interview Questions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _questionSets.entries.map((section) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.hairline)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                const SizedBox(height: 10),
                ...section.value.map((q) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  ', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w800)),
                          Expanded(child: Text(q, style: const TextStyle(color: AppTheme.textSecondary, height: 1.4))),
                        ],
                      ),
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
