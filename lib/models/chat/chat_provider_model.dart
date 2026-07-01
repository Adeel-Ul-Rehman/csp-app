// lib/models/chat/chat_provider_model.dart

enum AIProviderType {
  primary,
  fallback,
  lastResort,
  local,
}

class AIProviderModel {
  final String name;
  final String url;
  final AIProviderType type;
  final int dailyLimit;
  int usedToday;
  final double averageResponseTime;
  final bool isAvailable;
  final int priority;

  AIProviderModel({
    required this.name,
    required this.url,
    required this.type,
    required this.dailyLimit,
    this.usedToday = 0,
    this.averageResponseTime = 0.0,
    this.isAvailable = true,
    this.priority = 0,
  });

  bool get isRateLimited => usedToday >= dailyLimit;
  double get remaining => ((dailyLimit - usedToday) / dailyLimit * 100);

  void incrementUsage() {
    usedToday++;
  }

  void resetUsage() {
    usedToday = 0;
  }

  // Factory methods for each provider
  static AIProviderModel devToolBox() {
    return AIProviderModel(
      name: 'DevToolBox',
      url: 'https://devtoolbox-api.devtoolbox-api.workers.dev/ai/generate',
      type: AIProviderType.primary,
      dailyLimit: 500,
      priority: 0,
    );
  }

  static AIProviderModel pythonTgpt() {
    return AIProviderModel(
      name: 'python-tgpt',
      url: 'https://api.pythontgpt.com/generate',
      type: AIProviderType.fallback,
      dailyLimit: 1000,
      priority: 1,
    );
  }

  static AIProviderModel huggingFace() {
    return AIProviderModel(
      name: 'HuggingFace',
      url:
          'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1',
      type: AIProviderType.lastResort,
      dailyLimit: 50,
      priority: 2,
    );
  }

  static List<AIProviderModel> getAllProviders() {
    return [
      devToolBox(),
      pythonTgpt(),
      huggingFace(),
    ];
  }
}
