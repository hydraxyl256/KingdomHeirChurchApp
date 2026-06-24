// Kingdom Heir — Reflection Prompts
//
// Hardcoded discussion / reflection prompts grouped by topic. Used by:
//   - SermonDiscussionPrompts (read-only list on the Details page)
//   - SermonReflectionsPanel  (Q&A composer for the user to answer)

class ReflectionPrompts {
  const ReflectionPrompts._();

  /// All topics in display order. Used to seed the topic-chips bar.
  static const List<String> topics = <String>[
    'Faith',
    'Hope',
    'Prayer',
    'Identity',
    'Healing',
    'Family',
    'Leadership',
    'Provision',
    'Grace',
  ];

  /// Prompt questions for a given topic. Defaults to a generic pair.
  static List<String> forTopic(String? topic) {
    switch (topic) {
      case 'Faith':
        return const [
          'What is God asking you to trust Him for this week?',
          'Where have you seen His faithfulness recently?',
          'What fear do you need to release into His hands?',
        ];
      case 'Hope':
        return const [
          'What promise of God anchors you right now?',
          'How can you share that hope with someone else today?',
          'Where do you need to wait on the Lord with expectancy?',
        ];
      case 'Prayer':
        return const [
          'What is the deepest cry of your heart in this season?',
          'Who is on your prayer list that you have been neglecting?',
          'What would change if you spent 10 minutes in silence today?',
        ];
      case 'Identity':
        return const [
          'How does God see you — apart from what you do?',
          "Where have you been defining yourself by the world's standards?",
          'What truth about your identity in Christ needs repeating today?',
        ];
      case 'Healing':
        return const [
          'Where do you need physical, emotional, or spiritual healing?',
          'Have you been carrying a wound that you have not named?',
          'Who is someone you can extend the same grace to that you need?',
        ];
      case 'Family':
        return const [
          'How can you love your family more sacrificially this week?',
          'Is there a conversation you have been postponing?',
          'What would it look like to pray over each member of your home?',
        ];
      case 'Leadership':
        return const [
          'Who is one person you are intentionally discipling?',
          'Where is God asking you to step out in faith?',
          'What is a leader you look up to — and what have you learned?',
        ];
      case 'Provision':
        return const [
          'What need in your life do you need to bring before the Lord?',
          'Where have you been operating in scarcity instead of trust?',
          'How has God provided for you in a way you did not expect?',
        ];
      case 'Grace':
        return const [
          'Where do you need to extend grace to yourself this week?',
          'Is there someone you need to forgive today?',
          'What would it look like to live as if you are fully loved?',
        ];
      default:
        return const [
          'What is the Holy Spirit highlighting for you?',
          'How will you respond to this message this week?',
          'What is one step of obedience you can take today?',
        ];
    }
  }

  /// Default prompts (no topic) — used for sermons with empty topics.
  static List<String> get generic => forTopic(null);
}
