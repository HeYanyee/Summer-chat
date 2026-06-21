// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_card.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCharacterCardCollection on Isar {
  IsarCollection<CharacterCard> get characterCards => this.collection();
}

const CharacterCardSchema = CollectionSchema(
  name: r'CharacterCard',
  id: 1189056141123660726,
  properties: {
    r'autoReadReply': PropertySchema(
      id: 0,
      name: r'autoReadReply',
      type: IsarType.bool,
    ),
    r'avatar': PropertySchema(
      id: 1,
      name: r'avatar',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'hideReasoningBubbles': PropertySchema(
      id: 3,
      name: r'hideReasoningBubbles',
      type: IsarType.bool,
    ),
    r'lastRefreshTime': PropertySchema(
      id: 4,
      name: r'lastRefreshTime',
      type: IsarType.dateTime,
    ),
    r'longMemory': PropertySchema(
      id: 5,
      name: r'longMemory',
      type: IsarType.string,
    ),
    r'longMemoryHistory': PropertySchema(
      id: 6,
      name: r'longMemoryHistory',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'refreshCount': PropertySchema(
      id: 8,
      name: r'refreshCount',
      type: IsarType.long,
    ),
    r'refreshThreshold': PropertySchema(
      id: 9,
      name: r'refreshThreshold',
      type: IsarType.long,
    ),
    r'shortDescription': PropertySchema(
      id: 10,
      name: r'shortDescription',
      type: IsarType.string,
    ),
    r'shortMemory': PropertySchema(
      id: 11,
      name: r'shortMemory',
      type: IsarType.string,
    ),
    r'shortMemoryHistory': PropertySchema(
      id: 12,
      name: r'shortMemoryHistory',
      type: IsarType.stringList,
    )
  },
  estimateSize: _characterCardEstimateSize,
  serialize: _characterCardSerialize,
  deserialize: _characterCardDeserialize,
  deserializeProp: _characterCardDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'session': LinkSchema(
      id: -8773026280297309100,
      name: r'session',
      target: r'ChatSession',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _characterCardGetId,
  getLinks: _characterCardGetLinks,
  attach: _characterCardAttach,
  version: '3.1.0+1',
);

int _characterCardEstimateSize(
  CharacterCard object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.avatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.longMemory.length * 3;
  bytesCount += 3 + object.longMemoryHistory.length * 3;
  {
    for (var i = 0; i < object.longMemoryHistory.length; i++) {
      final value = object.longMemoryHistory[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.shortDescription;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.shortMemory.length * 3;
  bytesCount += 3 + object.shortMemoryHistory.length * 3;
  {
    for (var i = 0; i < object.shortMemoryHistory.length; i++) {
      final value = object.shortMemoryHistory[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _characterCardSerialize(
  CharacterCard object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.autoReadReply);
  writer.writeString(offsets[1], object.avatar);
  writer.writeString(offsets[2], object.description);
  writer.writeBool(offsets[3], object.hideReasoningBubbles);
  writer.writeDateTime(offsets[4], object.lastRefreshTime);
  writer.writeString(offsets[5], object.longMemory);
  writer.writeStringList(offsets[6], object.longMemoryHistory);
  writer.writeString(offsets[7], object.name);
  writer.writeLong(offsets[8], object.refreshCount);
  writer.writeLong(offsets[9], object.refreshThreshold);
  writer.writeString(offsets[10], object.shortDescription);
  writer.writeString(offsets[11], object.shortMemory);
  writer.writeStringList(offsets[12], object.shortMemoryHistory);
}

CharacterCard _characterCardDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CharacterCard();
  object.autoReadReply = reader.readBoolOrNull(offsets[0]);
  object.avatar = reader.readStringOrNull(offsets[1]);
  object.description = reader.readString(offsets[2]);
  object.hideReasoningBubbles = reader.readBoolOrNull(offsets[3]);
  object.id = id;
  object.lastRefreshTime = reader.readDateTimeOrNull(offsets[4]);
  object.longMemory = reader.readString(offsets[5]);
  object.longMemoryHistory = reader.readStringList(offsets[6]) ?? [];
  object.name = reader.readString(offsets[7]);
  object.refreshCount = reader.readLongOrNull(offsets[8]);
  object.refreshThreshold = reader.readLongOrNull(offsets[9]);
  object.shortDescription = reader.readStringOrNull(offsets[10]);
  object.shortMemory = reader.readString(offsets[11]);
  object.shortMemoryHistory = reader.readStringList(offsets[12]) ?? [];
  return object;
}

P _characterCardDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _characterCardGetId(CharacterCard object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _characterCardGetLinks(CharacterCard object) {
  return [object.session];
}

void _characterCardAttach(
    IsarCollection<dynamic> col, Id id, CharacterCard object) {
  object.id = id;
  object.session
      .attach(col, col.isar.collection<ChatSession>(), r'session', id);
}

extension CharacterCardQueryWhereSort
    on QueryBuilder<CharacterCard, CharacterCard, QWhere> {
  QueryBuilder<CharacterCard, CharacterCard, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CharacterCardQueryWhere
    on QueryBuilder<CharacterCard, CharacterCard, QWhereClause> {
  QueryBuilder<CharacterCard, CharacterCard, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<CharacterCard, CharacterCard, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterWhereClause> idBetween(
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

  QueryBuilder<CharacterCard, CharacterCard, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CharacterCardQueryFilter
    on QueryBuilder<CharacterCard, CharacterCard, QFilterCondition> {
  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      autoReadReplyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autoReadReply',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      autoReadReplyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autoReadReply',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      autoReadReplyEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoReadReply',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avatar',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avatar',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      avatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      hideReasoningBubblesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hideReasoningBubbles',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      hideReasoningBubblesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hideReasoningBubbles',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      hideReasoningBubblesEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hideReasoningBubbles',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      lastRefreshTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastRefreshTime',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      lastRefreshTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastRefreshTime',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      lastRefreshTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastRefreshTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      lastRefreshTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastRefreshTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      lastRefreshTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastRefreshTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      lastRefreshTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastRefreshTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longMemory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'longMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'longMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'longMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'longMemory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longMemory',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'longMemory',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longMemoryHistory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'longMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'longMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'longMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'longMemoryHistory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longMemoryHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'longMemoryHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longMemoryHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longMemoryHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longMemoryHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longMemoryHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longMemoryHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      longMemoryHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longMemoryHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'refreshCount',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'refreshCount',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refreshCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refreshCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refreshCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refreshCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshThresholdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'refreshThreshold',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshThresholdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'refreshThreshold',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshThresholdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refreshThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshThresholdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refreshThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshThresholdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refreshThreshold',
        value: value,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      refreshThresholdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refreshThreshold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'shortDescription',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'shortDescription',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shortDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shortDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shortDescription',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shortDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shortDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shortDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shortDescription',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortDescriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shortDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shortMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shortMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shortMemory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shortMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shortMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shortMemory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shortMemory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortMemory',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shortMemory',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shortMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shortMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shortMemoryHistory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shortMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shortMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shortMemoryHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shortMemoryHistory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortMemoryHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shortMemoryHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shortMemoryHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shortMemoryHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shortMemoryHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shortMemoryHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shortMemoryHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      shortMemoryHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shortMemoryHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension CharacterCardQueryObject
    on QueryBuilder<CharacterCard, CharacterCard, QFilterCondition> {}

extension CharacterCardQueryLinks
    on QueryBuilder<CharacterCard, CharacterCard, QFilterCondition> {
  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition> session(
      FilterQuery<ChatSession> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'session');
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterFilterCondition>
      sessionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'session', 0, true, 0, true);
    });
  }
}

extension CharacterCardQuerySortBy
    on QueryBuilder<CharacterCard, CharacterCard, QSortBy> {
  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByAutoReadReply() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoReadReply', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByAutoReadReplyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoReadReply', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> sortByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> sortByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByHideReasoningBubbles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideReasoningBubbles', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByHideReasoningBubblesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideReasoningBubbles', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByLastRefreshTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRefreshTime', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByLastRefreshTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRefreshTime', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> sortByLongMemory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longMemory', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByLongMemoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longMemory', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByRefreshCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshCount', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByRefreshCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshCount', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByRefreshThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshThreshold', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByRefreshThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshThreshold', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByShortDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortDescription', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByShortDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortDescription', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> sortByShortMemory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortMemory', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      sortByShortMemoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortMemory', Sort.desc);
    });
  }
}

extension CharacterCardQuerySortThenBy
    on QueryBuilder<CharacterCard, CharacterCard, QSortThenBy> {
  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByAutoReadReply() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoReadReply', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByAutoReadReplyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoReadReply', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByHideReasoningBubbles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideReasoningBubbles', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByHideReasoningBubblesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideReasoningBubbles', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByLastRefreshTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRefreshTime', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByLastRefreshTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRefreshTime', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenByLongMemory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longMemory', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByLongMemoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longMemory', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByRefreshCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshCount', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByRefreshCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshCount', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByRefreshThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshThreshold', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByRefreshThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refreshThreshold', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByShortDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortDescription', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByShortDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortDescription', Sort.desc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy> thenByShortMemory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortMemory', Sort.asc);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QAfterSortBy>
      thenByShortMemoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortMemory', Sort.desc);
    });
  }
}

extension CharacterCardQueryWhereDistinct
    on QueryBuilder<CharacterCard, CharacterCard, QDistinct> {
  QueryBuilder<CharacterCard, CharacterCard, QDistinct>
      distinctByAutoReadReply() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoReadReply');
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct> distinctByAvatar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct>
      distinctByHideReasoningBubbles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hideReasoningBubbles');
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct>
      distinctByLastRefreshTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRefreshTime');
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct> distinctByLongMemory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longMemory', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct>
      distinctByLongMemoryHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longMemoryHistory');
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct>
      distinctByRefreshCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refreshCount');
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct>
      distinctByRefreshThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refreshThreshold');
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct>
      distinctByShortDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shortDescription',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct> distinctByShortMemory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shortMemory', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CharacterCard, CharacterCard, QDistinct>
      distinctByShortMemoryHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shortMemoryHistory');
    });
  }
}

extension CharacterCardQueryProperty
    on QueryBuilder<CharacterCard, CharacterCard, QQueryProperty> {
  QueryBuilder<CharacterCard, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CharacterCard, bool?, QQueryOperations> autoReadReplyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoReadReply');
    });
  }

  QueryBuilder<CharacterCard, String?, QQueryOperations> avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatar');
    });
  }

  QueryBuilder<CharacterCard, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<CharacterCard, bool?, QQueryOperations>
      hideReasoningBubblesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hideReasoningBubbles');
    });
  }

  QueryBuilder<CharacterCard, DateTime?, QQueryOperations>
      lastRefreshTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRefreshTime');
    });
  }

  QueryBuilder<CharacterCard, String, QQueryOperations> longMemoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longMemory');
    });
  }

  QueryBuilder<CharacterCard, List<String>, QQueryOperations>
      longMemoryHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longMemoryHistory');
    });
  }

  QueryBuilder<CharacterCard, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CharacterCard, int?, QQueryOperations> refreshCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refreshCount');
    });
  }

  QueryBuilder<CharacterCard, int?, QQueryOperations>
      refreshThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refreshThreshold');
    });
  }

  QueryBuilder<CharacterCard, String?, QQueryOperations>
      shortDescriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shortDescription');
    });
  }

  QueryBuilder<CharacterCard, String, QQueryOperations> shortMemoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shortMemory');
    });
  }

  QueryBuilder<CharacterCard, List<String>, QQueryOperations>
      shortMemoryHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shortMemoryHistory');
    });
  }
}
