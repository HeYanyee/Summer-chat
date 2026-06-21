// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChatSessionCollection on Isar {
  IsarCollection<ChatSession> get chatSessions => this.collection();
}

const ChatSessionSchema = CollectionSchema(
  name: r'ChatSession',
  id: 1625796556473863540,
  properties: {
    r'apiSource': PropertySchema(
      id: 0,
      name: r'apiSource',
      type: IsarType.string,
    ),
    r'catchingId': PropertySchema(
      id: 1,
      name: r'catchingId',
      type: IsarType.long,
    ),
    r'character': PropertySchema(
      id: 2,
      name: r'character',
      type: IsarType.string,
    ),
    r'enabledTools': PropertySchema(
      id: 3,
      name: r'enabledTools',
      type: IsarType.bool,
    ),
    r'frequencyPenalty': PropertySchema(
      id: 4,
      name: r'frequencyPenalty',
      type: IsarType.double,
    ),
    r'includeThinking': PropertySchema(
      id: 5,
      name: r'includeThinking',
      type: IsarType.bool,
    ),
    r'isCharacterSession': PropertySchema(
      id: 6,
      name: r'isCharacterSession',
      type: IsarType.bool,
    ),
    r'lastMsgContent': PropertySchema(
      id: 7,
      name: r'lastMsgContent',
      type: IsarType.string,
    ),
    r'lastMsgTime': PropertySchema(
      id: 8,
      name: r'lastMsgTime',
      type: IsarType.dateTime,
    ),
    r'maxContextLength': PropertySchema(
      id: 9,
      name: r'maxContextLength',
      type: IsarType.long,
    ),
    r'maxTokens': PropertySchema(
      id: 10,
      name: r'maxTokens',
      type: IsarType.long,
    ),
    r'presencePenalty': PropertySchema(
      id: 11,
      name: r'presencePenalty',
      type: IsarType.double,
    ),
    r'streamResponse': PropertySchema(
      id: 12,
      name: r'streamResponse',
      type: IsarType.bool,
    ),
    r'systemPrompt': PropertySchema(
      id: 13,
      name: r'systemPrompt',
      type: IsarType.string,
    ),
    r'temperature': PropertySchema(
      id: 14,
      name: r'temperature',
      type: IsarType.double,
    ),
    r'title': PropertySchema(
      id: 15,
      name: r'title',
      type: IsarType.string,
    ),
    r'topP': PropertySchema(
      id: 16,
      name: r'topP',
      type: IsarType.double,
    )
  },
  estimateSize: _chatSessionEstimateSize,
  serialize: _chatSessionSerialize,
  deserialize: _chatSessionDeserialize,
  deserializeProp: _chatSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'character': IndexSchema(
      id: 1564562395447198696,
      name: r'character',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'character',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'messages': LinkSchema(
      id: 3071147317301372143,
      name: r'messages',
      target: r'ChatMessage',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _chatSessionGetId,
  getLinks: _chatSessionGetLinks,
  attach: _chatSessionAttach,
  version: '3.1.0+1',
);

int _chatSessionEstimateSize(
  ChatSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.apiSource.length * 3;
  {
    final value = object.character;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMsgContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.systemPrompt.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _chatSessionSerialize(
  ChatSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.apiSource);
  writer.writeLong(offsets[1], object.catchingId);
  writer.writeString(offsets[2], object.character);
  writer.writeBool(offsets[3], object.enabledTools);
  writer.writeDouble(offsets[4], object.frequencyPenalty);
  writer.writeBool(offsets[5], object.includeThinking);
  writer.writeBool(offsets[6], object.isCharacterSession);
  writer.writeString(offsets[7], object.lastMsgContent);
  writer.writeDateTime(offsets[8], object.lastMsgTime);
  writer.writeLong(offsets[9], object.maxContextLength);
  writer.writeLong(offsets[10], object.maxTokens);
  writer.writeDouble(offsets[11], object.presencePenalty);
  writer.writeBool(offsets[12], object.streamResponse);
  writer.writeString(offsets[13], object.systemPrompt);
  writer.writeDouble(offsets[14], object.temperature);
  writer.writeString(offsets[15], object.title);
  writer.writeDouble(offsets[16], object.topP);
}

ChatSession _chatSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChatSession(
    apiSource: reader.readStringOrNull(offsets[0]) ?? "暂未设置",
    character: reader.readStringOrNull(offsets[2]),
    enabledTools: reader.readBoolOrNull(offsets[3]) ?? false,
    frequencyPenalty: reader.readDoubleOrNull(offsets[4]) ?? 0.0,
    includeThinking: reader.readBoolOrNull(offsets[5]) ?? false,
    isCharacterSession: reader.readBoolOrNull(offsets[6]) ?? false,
    lastMsgContent: reader.readStringOrNull(offsets[7]),
    lastMsgTime: reader.readDateTimeOrNull(offsets[8]),
    maxContextLength: reader.readLongOrNull(offsets[9]) ?? 20,
    maxTokens: reader.readLongOrNull(offsets[10]) ?? 2000,
    presencePenalty: reader.readDoubleOrNull(offsets[11]) ?? 0.0,
    streamResponse: reader.readBoolOrNull(offsets[12]) ?? true,
    systemPrompt:
        reader.readStringOrNull(offsets[13]) ?? "You are a helpful assistant.",
    temperature: reader.readDoubleOrNull(offsets[14]) ?? 0.7,
    title: reader.readStringOrNull(offsets[15]) ?? "新对话",
    topP: reader.readDoubleOrNull(offsets[16]) ?? 0.9,
  );
  object.catchingId = reader.readLongOrNull(offsets[1]);
  object.id = id;
  return object;
}

P _chatSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? "暂未设置") as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset) ?? 20) as P;
    case 10:
      return (reader.readLongOrNull(offset) ?? 2000) as P;
    case 11:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 12:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 13:
      return (reader.readStringOrNull(offset) ?? "You are a helpful assistant.")
          as P;
    case 14:
      return (reader.readDoubleOrNull(offset) ?? 0.7) as P;
    case 15:
      return (reader.readStringOrNull(offset) ?? "新对话") as P;
    case 16:
      return (reader.readDoubleOrNull(offset) ?? 0.9) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chatSessionGetId(ChatSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chatSessionGetLinks(ChatSession object) {
  return [object.messages];
}

void _chatSessionAttach(
    IsarCollection<dynamic> col, Id id, ChatSession object) {
  object.id = id;
  object.messages
      .attach(col, col.isar.collection<ChatMessage>(), r'messages', id);
}

extension ChatSessionQueryWhereSort
    on QueryBuilder<ChatSession, ChatSession, QWhere> {
  QueryBuilder<ChatSession, ChatSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChatSessionQueryWhere
    on QueryBuilder<ChatSession, ChatSession, QWhereClause> {
  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause> characterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'character',
        value: [null],
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause>
      characterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'character',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause> characterEqualTo(
      String? character) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'character',
        value: [character],
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterWhereClause> characterNotEqualTo(
      String? character) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'character',
              lower: [],
              upper: [character],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'character',
              lower: [character],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'character',
              lower: [character],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'character',
              lower: [],
              upper: [character],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ChatSessionQueryFilter
    on QueryBuilder<ChatSession, ChatSession, QFilterCondition> {
  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apiSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apiSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apiSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apiSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apiSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apiSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apiSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiSource',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      apiSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apiSource',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      catchingIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'catchingId',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      catchingIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'catchingId',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      catchingIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'catchingId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      catchingIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'catchingId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      catchingIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'catchingId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      catchingIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'catchingId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'character',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'character',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'character',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'character',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'character',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'character',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'character',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'character',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'character',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'character',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'character',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      characterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'character',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      enabledToolsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabledTools',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      frequencyPenaltyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequencyPenalty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      frequencyPenaltyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequencyPenalty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      frequencyPenaltyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequencyPenalty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      frequencyPenaltyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequencyPenalty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      includeThinkingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeThinking',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      isCharacterSessionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCharacterSession',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMsgContent',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMsgContent',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMsgContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMsgContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMsgContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMsgContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMsgContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMsgContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMsgContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMsgContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMsgContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMsgContent',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMsgTime',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMsgTime',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMsgTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMsgTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMsgTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      lastMsgTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMsgTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      maxContextLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxContextLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      maxContextLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxContextLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      maxContextLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxContextLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      maxContextLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxContextLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      maxTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      maxTokensGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      maxTokensLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      maxTokensBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxTokens',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      presencePenaltyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'presencePenalty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      presencePenaltyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'presencePenalty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      presencePenaltyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'presencePenalty',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      presencePenaltyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'presencePenalty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      streamResponseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamResponse',
        value: value,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'systemPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'systemPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'systemPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'systemPrompt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'systemPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'systemPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'systemPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'systemPrompt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'systemPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      systemPromptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'systemPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      temperatureEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      temperatureGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      temperatureLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      temperatureBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'temperature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> topPEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topP',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> topPGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topP',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> topPLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topP',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> topPBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topP',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ChatSessionQueryObject
    on QueryBuilder<ChatSession, ChatSession, QFilterCondition> {}

extension ChatSessionQueryLinks
    on QueryBuilder<ChatSession, ChatSession, QFilterCondition> {
  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition> messages(
      FilterQuery<ChatMessage> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'messages');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      messagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', length, true, length, true);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      messagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', 0, true, 0, true);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      messagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', 0, false, 999999, true);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      messagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', 0, true, length, include);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      messagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'messages', length, include, 999999, true);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterFilterCondition>
      messagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'messages', lower, includeLower, upper, includeUpper);
    });
  }
}

extension ChatSessionQuerySortBy
    on QueryBuilder<ChatSession, ChatSession, QSortBy> {
  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByApiSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiSource', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByApiSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiSource', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByCatchingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchingId', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByCatchingIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchingId', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByCharacter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'character', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByCharacterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'character', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByEnabledTools() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabledTools', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByEnabledToolsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabledTools', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByFrequencyPenalty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyPenalty', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByFrequencyPenaltyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyPenalty', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByIncludeThinking() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeThinking', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByIncludeThinkingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeThinking', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByIsCharacterSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCharacterSession', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByIsCharacterSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCharacterSession', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByLastMsgContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMsgContent', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByLastMsgContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMsgContent', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByLastMsgTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMsgTime', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByLastMsgTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMsgTime', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByMaxContextLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxContextLength', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByMaxContextLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxContextLength', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByMaxTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxTokens', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByMaxTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxTokens', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByPresencePenalty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presencePenalty', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByPresencePenaltyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presencePenalty', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByStreamResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamResponse', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortByStreamResponseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamResponse', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortBySystemPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemPrompt', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      sortBySystemPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemPrompt', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByTopP() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topP', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> sortByTopPDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topP', Sort.desc);
    });
  }
}

extension ChatSessionQuerySortThenBy
    on QueryBuilder<ChatSession, ChatSession, QSortThenBy> {
  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByApiSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiSource', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByApiSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiSource', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByCatchingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchingId', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByCatchingIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchingId', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByCharacter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'character', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByCharacterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'character', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByEnabledTools() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabledTools', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByEnabledToolsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabledTools', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByFrequencyPenalty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyPenalty', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByFrequencyPenaltyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequencyPenalty', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByIncludeThinking() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeThinking', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByIncludeThinkingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeThinking', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByIsCharacterSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCharacterSession', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByIsCharacterSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCharacterSession', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByLastMsgContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMsgContent', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByLastMsgContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMsgContent', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByLastMsgTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMsgTime', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByLastMsgTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMsgTime', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByMaxContextLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxContextLength', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByMaxContextLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxContextLength', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByMaxTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxTokens', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByMaxTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxTokens', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByPresencePenalty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presencePenalty', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByPresencePenaltyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presencePenalty', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByStreamResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamResponse', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenByStreamResponseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamResponse', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenBySystemPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemPrompt', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy>
      thenBySystemPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'systemPrompt', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByTopP() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topP', Sort.asc);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QAfterSortBy> thenByTopPDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topP', Sort.desc);
    });
  }
}

extension ChatSessionQueryWhereDistinct
    on QueryBuilder<ChatSession, ChatSession, QDistinct> {
  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByApiSource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apiSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByCatchingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'catchingId');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByCharacter(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'character', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByEnabledTools() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabledTools');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct>
      distinctByFrequencyPenalty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequencyPenalty');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct>
      distinctByIncludeThinking() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeThinking');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct>
      distinctByIsCharacterSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCharacterSession');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByLastMsgContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMsgContent',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByLastMsgTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMsgTime');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct>
      distinctByMaxContextLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxContextLength');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByMaxTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxTokens');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct>
      distinctByPresencePenalty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'presencePenalty');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByStreamResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamResponse');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctBySystemPrompt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'systemPrompt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'temperature');
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatSession, ChatSession, QDistinct> distinctByTopP() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topP');
    });
  }
}

extension ChatSessionQueryProperty
    on QueryBuilder<ChatSession, ChatSession, QQueryProperty> {
  QueryBuilder<ChatSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChatSession, String, QQueryOperations> apiSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apiSource');
    });
  }

  QueryBuilder<ChatSession, int?, QQueryOperations> catchingIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'catchingId');
    });
  }

  QueryBuilder<ChatSession, String?, QQueryOperations> characterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'character');
    });
  }

  QueryBuilder<ChatSession, bool, QQueryOperations> enabledToolsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabledTools');
    });
  }

  QueryBuilder<ChatSession, double, QQueryOperations>
      frequencyPenaltyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequencyPenalty');
    });
  }

  QueryBuilder<ChatSession, bool, QQueryOperations> includeThinkingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeThinking');
    });
  }

  QueryBuilder<ChatSession, bool, QQueryOperations>
      isCharacterSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCharacterSession');
    });
  }

  QueryBuilder<ChatSession, String?, QQueryOperations>
      lastMsgContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMsgContent');
    });
  }

  QueryBuilder<ChatSession, DateTime?, QQueryOperations> lastMsgTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMsgTime');
    });
  }

  QueryBuilder<ChatSession, int, QQueryOperations> maxContextLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxContextLength');
    });
  }

  QueryBuilder<ChatSession, int, QQueryOperations> maxTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxTokens');
    });
  }

  QueryBuilder<ChatSession, double, QQueryOperations>
      presencePenaltyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'presencePenalty');
    });
  }

  QueryBuilder<ChatSession, bool, QQueryOperations> streamResponseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamResponse');
    });
  }

  QueryBuilder<ChatSession, String, QQueryOperations> systemPromptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'systemPrompt');
    });
  }

  QueryBuilder<ChatSession, double, QQueryOperations> temperatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'temperature');
    });
  }

  QueryBuilder<ChatSession, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ChatSession, double, QQueryOperations> topPProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topP');
    });
  }
}
