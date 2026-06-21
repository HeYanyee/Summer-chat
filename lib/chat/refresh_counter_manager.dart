import 'package:summer/models/character_card.dart';
import 'package:summer/services/storage_service.dart';

class RefreshCounterManager {
  final CharacterCard characterCard;
  
  RefreshCounterManager({required this.characterCard});
  
  /// 检查是否需要刷新记忆
  Future<bool> checkAndUpdateCount() async {
    if (characterCard.refreshCount == -1) return false;
    
    characterCard.refreshCount = (characterCard.refreshCount ?? 0) + 1;
    
    final needsRefresh = characterCard.refreshCount! >= (characterCard.refreshThreshold ?? 0);
    
    if (needsRefresh) {
      characterCard.refreshCount = 0;
      characterCard.lastRefreshTime = DateTime.now();
    }
    
    await IsarStorageService.saveCharacterCard(characterCard);
    return needsRefresh;
  }
  
  /// 重置计数器
  Future<void> resetCount() async {
    characterCard.refreshCount = 0;
    await IsarStorageService.saveCharacterCard(characterCard);
  }
  
  /// 获取当前计数状态
  Map<String, int> getCountStatus() {
    return {
      'current': characterCard.refreshCount ?? 0,
      'threshold': characterCard.refreshThreshold ?? 0,
    };
  }
}