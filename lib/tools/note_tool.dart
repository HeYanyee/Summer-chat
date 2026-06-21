import 'package:isar/isar.dart';
import 'package:summer/services/storage_service.dart';

part 'note_tool.g.dart'; // 需要运行 build_runner 生成
// flutter pub run build_runner build --delete-conflicting-outputs

/// 笔记模型
@collection
class Note {
  Id id = Isar.autoIncrement; // 自增ID
  
  @Index(unique: true) // 笔记名称唯一索引
  late String name;
  
  late String content;
  
  DateTime? createdAt;
  DateTime? updatedAt;

  Note({
    required this.name,
    this.content = '', // 初始为空字符串
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  /// JSON 序列化
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      name: json['name'] as String,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    )..id = json['id'] as int? ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class NoteService {
  // 获取所有笔记
  static Future<List<Note>> getAllNotes() async {
    final notes = await IsarStorageService.getAllNotes();
    return notes;
  }

  Future<String> handleNoteRequest(Map<String, dynamic> args) async {
    switch(args['action']) {
      case 'read':
        final name = args['name'] as String? ?? '';
        final note = await IsarStorageService.getNoteByName(name);
        if (note == null) {
          return '笔记未找到';
        }
        return '【${note.name}】\n${note.content}';
      case 'create':
        final name = args['name'] as String? ?? 'Untitled Note';
        final content = args['content'] as String? ?? '';
        final note = Note(name: name, content: content);
        await IsarStorageService.saveNote(note);
        return '笔记 "$name" 已创建';   
      
      case 'write':
        final name = args['name'] as String? ?? '';
        final content = args['content'] as String? ?? '';
        final note = await IsarStorageService.getNoteByName(name);
        if (note == null) {
          return '笔记未找到';
        }
        if (content.isEmpty) {
          return '内容不能为空';
        }
        note.content = note.content + content;
        note.updatedAt = DateTime.now();
        await IsarStorageService.saveNote(note);
        return '笔记 "${note.name}" 已追加内容';

      case 'rewrite':
        final name = args['name'] as String? ?? '';
        final content = args['content'] as String? ?? '';
        final note = await IsarStorageService.getNoteByName(name);
        if (note == null) {
          return '笔记未找到';
        }
        if (content.isEmpty) {
          return '内容不能为空';
        }
        note.content = content;
        note.updatedAt = DateTime.now();
        await IsarStorageService.saveNote(note);
        return '笔记 "${note.name}" 已重写';
      
      case 'update':
        final name = args['name'] as String? ?? '';
        final content = args['content'] as String? ?? '';
        final note = await IsarStorageService.getNoteByName(name);
        if (note == null) {
          return '笔记未找到';
        }
        if (content.isEmpty) {
          return '内容不能为空';
        }
        note.content = content;
        note.updatedAt = DateTime.now();
        await IsarStorageService.saveNote(note);
        return '笔记 "${note.name}" 已更新';
      
      case 'delete':
        final name = args['name'] as String? ?? '';
        final note = await IsarStorageService.getNoteByName(name);
        if (note == null) {
          return '笔记未找到';
        }
        await IsarStorageService.deleteNote(note.id);
        return '笔记 "${note.name}" 已删除';
      
      case 'list':
        final notes = await getAllNotes();
        if (notes.isEmpty) {
          return '没有笔记';
        }
        return notes.map((n) => '- ${n.name} (ID: ${n.id})').join('\n');
      
      default:
        return '未知操作';
    }
  }

}