import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../models/chat_message.dart';
import '../models/tool.dart'; // 新增导入
import '../utils/constants.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../services/voice_service.dart';
import '../services/message_parser.dart'; // 新增导入

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String role;
  final String timestampText;
  final double horizontalMargin;
  final double fontSize; // 可配置字体大小
  final VoidCallback onRollbackComplete; // 回溯完成后的回调
  final Future<void> Function(ChatMessage) onRollbackRequested; // 触发回溯的回调
  final bool isLastMessage; // 是否是最后一条消息
  final VoidCallback onRegenerateRequested; // 重新生成回调
  final VoidCallback? onStartLoading;
  final VoidCallback? onStopLoading;
  final bool hideReasoning;

  // 版本控制信息
  final int? versionIndex; // 1-based 当前版本序号
  final int? versionTotal; // 总版本数
  final VoidCallback? onPrevVersion; // 切换上一版本
  final VoidCallback? onNextVersion; // 切换下一版本

  // 角色颜色配置
  static final roleColors = {
    'user': {'bubble': AppColors.primary, 'text': Colors.white},
    'assistant': {'bubble': Colors.white, 'text': Colors.black87},
    'assistant_reasoning': {
      'bubble': AppColors.grey500.withAlpha(32),
      'text': Colors.black87,
    },
    'system': {'bubble': Colors.white, 'text': Colors.black87},
    'notice': {'bubble': Colors.white, 'text': Colors.black87},
  };

  const ChatBubble({
    super.key,
    required this.message,
    required this.role,
    required this.timestampText,
    this.horizontalMargin = 12.0,
    this.fontSize = 16.0,
    required this.onRollbackComplete,
    required this.onRollbackRequested,
    required this.isLastMessage,
    required this.onRegenerateRequested,
    this.onStartLoading,
    this.onStopLoading,
    required this.hideReasoning,
    this.versionIndex,
    this.versionTotal = 1,
    this.onPrevVersion,
    this.onNextVersion,
  });

  @override
  Widget build(BuildContext context) {
    // 如果是隐藏消息，不显示
    if (message.shouldHide) {
      return const SizedBox.shrink();
    }

    // 如果是工具会话消息，使用专门的构建器
    if (MessageParser.isToolSessionMessage(message)) {
      return _buildToolSessionMessage(context);
    }

    if (role == 'assistant_reasoning' && hideReasoning) {
      return const SizedBox.shrink();
    }

    // 获取角色颜色配置（默认为assistant）
    final colors = roleColors[role] ?? roleColors['system']!;
    final bubbleColor = colors['bubble']!;
    final textColor = colors['text']!;

    // 检查是否是assistant角色
    final isAssistant = role == 'assistant';

    return GestureDetector(
      onSecondaryTapDown:
          (details) => _showPopupMenu(context, details.globalPosition),
      onLongPress: () {
        final box = context.findRenderObject() as RenderBox;
        final center = box.localToGlobal(box.size.center(Offset.zero));
        _showPopupMenu(context, center);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 4),
        child: Column(
          crossAxisAlignment:
              role == 'user'
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            // 消息内容气泡
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          role == 'user'
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                      bottomRight:
                          role == 'user'
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: _buildContent(context, textColor, bubbleColor),
                  ),
                ),

                // 播放按钮（仅assistant角色）
                if (isAssistant)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () async {
                          try {
                            if (onStartLoading != null) onStartLoading!();
                            final content = MessageParser.getDisplayContent(
                              message,
                            );
                            await VoiceService().textToSpeech(
                              content,
                              message.id,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('播放失败: ${e.toString()}')),
                            );
                          } finally {
                            if (onStopLoading != null) onStopLoading!();
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.mic,
                            size: 18,
                            color: AppColors.warmGrey200,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 时间戳及版本导航
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 6, left: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timestampText,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  if (versionTotal != null && versionTotal! > 1)
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onPrevVersion,
                          child: Icon(
                            Icons.chevron_left,
                            size: 14,
                            color:
                                (versionIndex ?? 1) > 1
                                    ? Colors.grey
                                    : Colors.grey.shade300,
                          ),
                        ),
                        Text(
                          '(${versionIndex ?? 0}/${versionTotal ?? 0})',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        GestureDetector(
                          onTap: onNextVersion,
                          child: Icon(
                            Icons.chevron_right,
                            size: 14,
                            color:
                                (versionIndex ?? 0) < (versionTotal ?? 0)
                                    ? Colors.grey
                                    : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建工具会话聚合消息
  Widget _buildToolSessionMessage(BuildContext context) {
    final sessionData = MessageParser.parseToolSession(message);
    if (sessionData == null) {
      return _buildFallbackMessage(context);
    }

    final session = sessionData.session;
    final isExpanded = sessionData.isExpanded;
    final colors = roleColors['assistant']!;
    final bubbleColor = colors['bubble']!;
    final textColor = colors['text']!;

    return GestureDetector(
      onSecondaryTapDown:
          (details) => _showPopupMenu(context, details.globalPosition),
      onLongPress: () {
        final box = context.findRenderObject() as RenderBox;
        final center = box.localToGlobal(box.size.center(Offset.zero));
        _showPopupMenu(context, center);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主消息气泡
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 主要内容，支持与普通assistant消息一致的<thinking>显示格式
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: _buildAssistantMessageWithThinking(
                      session.finalContent ?? '',
                      textColor,
                      bubbleColor,
                    ),
                  ),

                  // 工具调用详情（可折叠）
                  if (session.rounds.isNotEmpty)
                    _buildToolDetailsSection(
                      context,
                      session,
                      textColor,
                      bubbleColor,
                    ),
                ],
              ),
            ),

            // 时间戳和版本指示器（与assistant消息保持一致）
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 6, left: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timestampText,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  // 版本控制指示器（与assistant消息完全相同的逻辑）
                  if (versionTotal != null && versionTotal! > 1)
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onPrevVersion,
                          child: Icon(
                            Icons.chevron_left,
                            size: 14,
                            color:
                                (versionIndex ?? 1) > 1
                                    ? Colors.grey
                                    : Colors.grey.shade300,
                          ),
                        ),
                        Text(
                          '(${versionIndex ?? 0}/${versionTotal ?? 0})',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        GestureDetector(
                          onTap: onNextVersion,
                          child: Icon(
                            Icons.chevron_right,
                            size: 14,
                            color:
                                (versionIndex ?? 0) < (versionTotal ?? 0)
                                    ? Colors.grey
                                    : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  // 工具调用状态指示器（保留原有功能）
                  if (session.status != ToolSessionStatus.completed)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(session.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(session.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(session.status),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建工具调用详情区域
  Widget _buildToolDetailsSection(
    BuildContext context,
    ToolSession session,
    Color textColor,
    Color bubbleColor,
  ) {
    final totalCalls = session.totalToolCalls;
    final successCount = session.successfulToolCalls;
    final failCount = session.failedToolCalls;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
        border: Border(
          top: BorderSide(color: textColor.withOpacity(0.1), width: 1),
        ),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.build, size: 16, color: textColor.withOpacity(0.6)),
        title: Text(
          '工具调用 · $totalCalls次调用 · ${session.rounds.length}轮',
          style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
        ),
        subtitle:
            failCount > 0
                ? Text(
                  '⚠️ $failCount 个工具调用失败',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.withOpacity(0.7),
                  ),
                )
                : null,
        trailing: Icon(
          Icons.keyboard_arrow_down,
          size: 16,
          color: textColor.withOpacity(0.6),
        ),
        children: [
          ...session.rounds.map(
            (round) => _buildToolRoundTile(round, textColor),
          ),
          // 统计信息
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bubbleColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.check_circle,
                  '成功',
                  successCount,
                  Colors.green,
                ),
                _buildStatItem(Icons.error, '失败', failCount, Colors.red),
                _buildStatItem(
                  Icons.timer,
                  '耗时',
                  session.totalDuration.inMilliseconds,
                  null,
                  isMs: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单轮工具调用
  Widget _buildToolRoundTile(ToolRound round, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '第 ${round.roundNumber + 1} 轮 (${round.duration.inMilliseconds}ms)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.7),
            ),
          ),
          // 新增：显示AI的中间思考
        if (round.intermediateThinking != null && round.intermediateThinking!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border(left: BorderSide(color: Colors.blue, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI思考过程:',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                _buildMarkdown(
                  round.intermediateThinking!,
                  textColor,
                  Colors.white, // bubbleColor
                  fontSize: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...round.toolCalls.asMap().entries.map((entry) {
            final index = entry.key;
            final toolCall = entry.value;
            final result =
                round.results.length > index ? round.results[index] : null;

            return _buildToolCallItem(toolCall, result, textColor);
          }),
        ],
      ),
    );
  }

  /// 构建单个工具调用
  Widget _buildToolCallItem(
    ToolCallInfo toolCall,
    ToolResultInfo? result,
    Color textColor,
  ) {
    final isSuccess = result?.success ?? false;
    final statusColor = isSuccess ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                size: 12,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  toolCall.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (result != null)
                Text(
                  '${result.executionTime.inMilliseconds}ms',
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          if (toolCall.arguments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                '参数: ${_formatArguments(toolCall.arguments)}',
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.5),
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (result != null && result.result != null && isSuccess)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                '结果: ${result.summary}',
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (result != null && !isSuccess && result.error != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                '错误: ${result.error}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    IconData icon,
    String label,
    int value,
    Color? color, {
    bool isMs = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ${isMs ? '$value ms' : value}',
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }

  /// 格式化参数显示
  String _formatArguments(Map<String, dynamic> args) {
    if (args.isEmpty) return '{}';
    final keys = args.keys.take(2).join(', ');
    if (args.length > 2) {
      return '$keys, ...';
    }
    return keys;
  }

  /// 获取状态颜色
  Color _getStatusColor(ToolSessionStatus status) {
    switch (status) {
      case ToolSessionStatus.executing:
        return Colors.orange;
      case ToolSessionStatus.completed:
        return Colors.green;
      case ToolSessionStatus.failed:
        return Colors.red;
      case ToolSessionStatus.cancelled:
        return Colors.grey;
    }
  }

  /// 获取状态文本
  String _getStatusText(ToolSessionStatus status) {
    switch (status) {
      case ToolSessionStatus.executing:
        return '执行中';
      case ToolSessionStatus.completed:
        return '已完成';
      case ToolSessionStatus.failed:
        return '失败';
      case ToolSessionStatus.cancelled:
        return '已取消';
    }
  }

  /// 降级显示（解析失败时）
  Widget _buildFallbackMessage(BuildContext context) {
    final colors = roleColors['assistant']!;
    final bubbleColor = colors['bubble']!;
    final textColor = colors['text']!;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          message.content,
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
      ),
    );
  }

  // ... 其余方法保持不变（_showPopupMenu, _buildContent, _buildMarkdown等）

  void _showPopupMenu(BuildContext context, Offset position) {
    final menuItems = <PopupMenuItem>[];

    // 获取显示内容（如果是工具会话，获取实际内容）
    final displayContent = MessageParser.getDisplayContent(message);

    menuItems.add(
      PopupMenuItem(
        child: const Text('复制'),
        onTap: () {
          if (role == 'user') {
            final reg = RegExp(r'^\{.*?text:(.*)\}$', dotAll: true);
            final match = reg.firstMatch(message.content);
            Clipboard.setData(
              ClipboardData(text: match?.group(1)?.trim() ?? message.content),
            );
          } else {
            Clipboard.setData(ClipboardData(text: displayContent));
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
        },
      ),
    );

    if (isLastMessage) {
      menuItems.add(
        PopupMenuItem(
          child: const Text('重新生成'),
          onTap: () async {
            try {
              onRegenerateRequested();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('重新生成失败: ${e.toString()}')),
              );
            }
          },
        ),
      );
    } else {
      //if (role != 'user') {
      menuItems.add(
        PopupMenuItem(
          child: const Text('回溯至此处'),
          onTap: () async {
            try {
              await onRollbackRequested(message);
              onRollbackComplete();
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('回溯失败: ${e.toString()}')));
            }
          },
        ),
      );
    }

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: menuItems,
    );
  }

  Widget _buildContent(
    BuildContext context,
    Color textColor,
    Color bubbleColor,
  ) {
    // 优先使用 MessageParser 获取显示内容
    final displayContent = MessageParser.getDisplayContent(message);

    switch (role) {
      case 'user':
        String content = message.content;
        final reg = RegExp(r'^\{.*?text:(.*)\}$', dotAll: true);
        final match = reg.firstMatch(content);
        if (match != null) {
          content = match.group(1)!.trim();
        }
        return Text(
          content,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
          ),
        );
      case 'notice':
        return Text(
          '[Notice] $displayContent',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
          ),
        );
      case 'system':
        return Text(
          '[System] $displayContent',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        );
      case 'assistant_reasoning':
        return Container(
          decoration: BoxDecoration(
            color: bubbleColor.withOpacity(0.1),
            border: Border(
              left: BorderSide(color: textColor.withOpacity(0.5), width: 4.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: _buildMarkdown(
            displayContent,
            textColor,
            bubbleColor,
            fontSize: fontSize,
          ),
        );
      case 'assistant':
      default:
        return _buildAssistantMessageWithThinking(
          displayContent,
          textColor,
          bubbleColor,
        );
    }
  }

  Widget _buildAssistantMessageWithThinking(
    String content,
    Color textColor,
    Color bubbleColor,
  ) {
    final thinkingRegex = RegExp(
      r'<thinking>(.*?)(?:</thinking>|$)',
      dotAll: true,
    );

    if (thinkingRegex.hasMatch(content)) {
      List<Widget> segments = [];
      int currentIndex = 0;

      final matches = thinkingRegex.allMatches(content);
      for (final match in matches) {
        final hasClosingTag = match.group(0)?.contains('</thinking>') ?? false;

        if (match.start > currentIndex) {
          var normalText = content.substring(currentIndex, match.start);
          normalText = normalText.replaceAll('</thinking>', '');
          if (normalText.isNotEmpty) {
            segments.add(
              _buildMarkdown(
                normalText,
                textColor,
                bubbleColor,
                fontSize: fontSize,
              ),
            );
          }
        }

        final thinkingContent = match.group(1)?.trim() ?? '';

        segments.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '思考中...',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.warmGrey200,
                    border: Border(
                      left: BorderSide(
                        color: textColor.withOpacity(0.5),
                        width: 4.0,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: _buildMarkdown(
                    thinkingContent,
                    textColor,
                    bubbleColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasClosingTag)
                  Text(
                    '思考已结束',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.4),
                    ),
                    textAlign: TextAlign.right,
                  ),
              ],
            ),
          ),
        );

        currentIndex = match.end;
      }

      if (currentIndex < content.length) {
        var remainingText = content.substring(currentIndex);
        remainingText = remainingText.replaceAll('</thinking>', '');
        if (remainingText.isNotEmpty) {
          segments.add(
            _buildMarkdown(
              remainingText,
              textColor,
              bubbleColor,
              fontSize: fontSize,
            ),
          );
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: segments,
      );
    } else {
      return _buildMarkdown(
        content,
        textColor,
        bubbleColor,
        fontSize: fontSize,
      );
    }
  }

  Widget _buildMarkdown(
    String content,
    Color textColor,
    Color bubbleColor, {
    double fontSize = 14,
  }) {
    return Markdown(
      data: content,
      selectable: false,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: textColor,
          fontSize: fontSize,
          height: 1.5,
          fontWeight: FontWeight.w300,
        ),
        a: TextStyle(
          color: AppColors.info,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w500,
        ),
        strong: TextStyle(fontWeight: FontWeight.w500, color: textColor),
        em: TextStyle(fontStyle: FontStyle.italic, color: textColor),
        code: TextStyle(
          fontFamily: 'FiraCode',
          fontSize: 12,
          color: Colors.orange[700],
          backgroundColor: AppColors.warmGrey400,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.warmGrey600, width: 1.0),
          ),
        ),
        h1: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        h2: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        h3: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        h4: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        h5: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        h6: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor.withAlpha(200),
        ),
        listBullet: TextStyle(color: textColor, fontSize: 16),
        blockquote: TextStyle(
          color: AppColors.warmGrey400,
          fontStyle: FontStyle.italic,
        ),
        img: TextStyle(
          color: textColor.withAlpha(200),
          fontStyle: FontStyle.italic,
          fontSize: 12,
        ),
        checkbox: TextStyle(color: AppColors.info, fontSize: 18),
        codeblockDecoration: BoxDecoration(
          color: bubbleColor.withAlpha(24),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: bubbleColor.withAlpha(48)),
        ),
        blockSpacing: 8.0,
        blockquotePadding: EdgeInsets.all(12),
        blockquoteDecoration: BoxDecoration(
          color: bubbleColor.withAlpha(8),
          border: Border(left: BorderSide(color: AppColors.info, width: 4)),
        ),
      ),
      builders: {
        'code': CodeElementBuilder(
          bubbleColor: bubbleColor,
          showLanguageLabel: true,
        ),
        'blockquote': BlockquoteBuilder(bubbleColor: bubbleColor),
        'img': ImageElementBuilder(textColor: textColor),
      },
    );
  }
}

class ImageElementBuilder extends MarkdownElementBuilder {
  final Color textColor;

  ImageElementBuilder({required this.textColor});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final src = element.attributes['src'] ?? '';
    final title = element.attributes['title'];
    final alt = element.attributes['alt'];

    return _buildImageWithErrorHandling(src, title: title, alt: alt);
  }

  Widget _buildImageWithErrorHandling(
    String src, {
    String? title,
    String? alt,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 限制图片最大宽度为屏幕宽度的80%
        final maxWidth = constraints.maxWidth;
        final maxHeight = maxWidth * 0.75; // 保持4:3宽高比

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 图片容器
              Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    src,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // 图片加载失败时显示错误占位符
                      return _buildErrorPlaceholder(
                        maxWidth: maxWidth * 0.25,
                        maxHeight: maxHeight * 0.25,
                        error: error,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingIndicator(
                        maxWidth: maxWidth,
                        maxHeight: maxHeight,
                        loadingProgress: loadingProgress,
                      );
                    },
                  ),
                ),
              ),

              // 图片标题/描述
              if (title != null || alt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    title ?? alt!,
                    style: TextStyle(
                      color: textColor.withAlpha(200),
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorPlaceholder({
    required double maxWidth,
    required double maxHeight,
    required Object error,
  }) {
    return Container(
      width: maxWidth,
      height: maxHeight,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (error is NetworkImageLoadException)
            Text(
              '错误: ${error.statusCode}',
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator({
    required double maxWidth,
    required double maxHeight,
    required ImageChunkEvent loadingProgress,
  }) {
    return Container(
      width: maxWidth,
      height: maxHeight,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          value:
              loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
        ),
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  final Color bubbleColor;
  final bool showLanguageLabel;

  CodeElementBuilder({
    required this.bubbleColor,
    this.showLanguageLabel = false,
  });

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language = showLanguageLabel ? _getCodeLanguage(element) : null;
    final isBlock =
        element.attributes['class'] != null &&
        element.attributes['class']!.contains('language');

    if (isBlock) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (language != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bubbleColor.withAlpha(64),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Text(
                language.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey500,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: bubbleColor.withOpacity(0.1),
              borderRadius:
                  language != null
                      ? const BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      )
                      : BorderRadius.circular(6),
              border: Border.all(
                color: bubbleColor.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  element.textContent,
                  style: const TextStyle(fontFamily: 'FiraCode', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bubbleColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          element.textContent,
          style: const TextStyle(fontFamily: 'FiraCode', fontSize: 14),
        ),
      );
    }
  }

  String _getCodeLanguage(md.Element element) {
    final classValue = element.attributes['class'] ?? '';
    final match = RegExp(r'language-(\w+)').firstMatch(classValue);
    return match?.group(1) ?? 'code';
  }
}

class BlockquoteBuilder extends MarkdownElementBuilder {
  final Color bubbleColor;

  BlockquoteBuilder({required this.bubbleColor});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bubbleColor.withOpacity(0.1),
        border: Border(
          left: BorderSide(color: bubbleColor.withOpacity(0.5), width: 4.0),
        ),
      ),
      child: Text(
        element.textContent,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: bubbleColor.withOpacity(0.8),
        ),
      ),
    );
  }
}
