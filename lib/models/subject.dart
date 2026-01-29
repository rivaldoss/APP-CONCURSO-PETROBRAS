class Subject {
  final String id;
  final String title;
  final List<Topic> topics;

  const Subject({
    required this.id,
    required this.title,
    required this.topics,
  });
}

class Topic {
  final String id;
  final String title;
  final TopicPriority priority;

  const Topic({
    required this.id,
    required this.title,
    this.priority = TopicPriority.normal,
  });
}

enum TopicPriority { normal, high }
