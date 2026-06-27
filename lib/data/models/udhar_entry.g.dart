// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'udhar_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUdharEntryCollection on Isar {
  IsarCollection<UdharEntry> get udharEntrys => this.collection();
}

const UdharEntrySchema = CollectionSchema(
  name: r'UdharEntry',
  id: 2340468574789743377,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'iGave': PropertySchema(
      id: 3,
      name: r'iGave',
      type: IsarType.bool,
    ),
    r'isSettled': PropertySchema(
      id: 4,
      name: r'isSettled',
      type: IsarType.bool,
    ),
    r'linkedTransactionId': PropertySchema(
      id: 5,
      name: r'linkedTransactionId',
      type: IsarType.string,
    ),
    r'personName': PropertySchema(
      id: 6,
      name: r'personName',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(
      id: 7,
      name: r'phone',
      type: IsarType.string,
    ),
    r'reason': PropertySchema(
      id: 8,
      name: r'reason',
      type: IsarType.string,
    ),
    r'settledAmount': PropertySchema(
      id: 9,
      name: r'settledAmount',
      type: IsarType.double,
    ),
    r'settledAt': PropertySchema(
      id: 10,
      name: r'settledAt',
      type: IsarType.dateTime,
    ),
    r'settledVia': PropertySchema(
      id: 11,
      name: r'settledVia',
      type: IsarType.string,
    ),
    r'settlementNote': PropertySchema(
      id: 12,
      name: r'settlementNote',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 13,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _udharEntryEstimateSize,
  serialize: _udharEntrySerialize,
  deserialize: _udharEntryDeserialize,
  deserializeProp: _udharEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _udharEntryGetId,
  getLinks: _udharEntryGetLinks,
  attach: _udharEntryAttach,
  version: '3.1.0+1',
);

int _udharEntryEstimateSize(
  UdharEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.linkedTransactionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.personName.length * 3;
  {
    final value = object.phone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reason.length * 3;
  {
    final value = object.settledVia;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.settlementNote;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _udharEntrySerialize(
  UdharEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeBool(offsets[3], object.iGave);
  writer.writeBool(offsets[4], object.isSettled);
  writer.writeString(offsets[5], object.linkedTransactionId);
  writer.writeString(offsets[6], object.personName);
  writer.writeString(offsets[7], object.phone);
  writer.writeString(offsets[8], object.reason);
  writer.writeDouble(offsets[9], object.settledAmount);
  writer.writeDateTime(offsets[10], object.settledAt);
  writer.writeString(offsets[11], object.settledVia);
  writer.writeString(offsets[12], object.settlementNote);
  writer.writeString(offsets[13], object.uuid);
}

UdharEntry _udharEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UdharEntry();
  object.amount = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.iGave = reader.readBool(offsets[3]);
  object.id = id;
  object.isSettled = reader.readBool(offsets[4]);
  object.linkedTransactionId = reader.readStringOrNull(offsets[5]);
  object.personName = reader.readString(offsets[6]);
  object.phone = reader.readStringOrNull(offsets[7]);
  object.reason = reader.readString(offsets[8]);
  object.settledAmount = reader.readDoubleOrNull(offsets[9]);
  object.settledAt = reader.readDateTimeOrNull(offsets[10]);
  object.settledVia = reader.readStringOrNull(offsets[11]);
  object.settlementNote = reader.readStringOrNull(offsets[12]);
  object.uuid = reader.readString(offsets[13]);
  return object;
}

P _udharEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _udharEntryGetId(UdharEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _udharEntryGetLinks(UdharEntry object) {
  return [];
}

void _udharEntryAttach(IsarCollection<dynamic> col, Id id, UdharEntry object) {
  object.id = id;
}

extension UdharEntryByIndex on IsarCollection<UdharEntry> {
  Future<UdharEntry?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  UdharEntry? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<UdharEntry?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<UdharEntry?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(UdharEntry object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(UdharEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<UdharEntry> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<UdharEntry> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension UdharEntryQueryWhereSort
    on QueryBuilder<UdharEntry, UdharEntry, QWhere> {
  QueryBuilder<UdharEntry, UdharEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension UdharEntryQueryWhere
    on QueryBuilder<UdharEntry, UdharEntry, QWhereClause> {
  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> uuidNotEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UdharEntryQueryFilter
    on QueryBuilder<UdharEntry, UdharEntry, QFilterCondition> {
  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> iGaveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iGave',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> isSettledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSettled',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedTransactionId',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedTransactionId',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedTransactionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedTransactionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedTransactionId',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      linkedTransactionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedTransactionId',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> personNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      personNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      personNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> personNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      personNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      personNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      personNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> personNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      personNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      personNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settledAmount',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settledAmount',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settledAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settledAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settledAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settledAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settledAt',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settledAt',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> settledAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> settledAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> settledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settledVia',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settledVia',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> settledViaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settledVia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settledVia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settledVia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> settledViaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settledVia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settledVia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settledVia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settledVia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> settledViaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settledVia',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settledVia',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settledViaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settledVia',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'settlementNote',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'settlementNote',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settlementNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'settlementNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'settlementNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'settlementNote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'settlementNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'settlementNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'settlementNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'settlementNote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'settlementNote',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition>
      settlementNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'settlementNote',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension UdharEntryQueryObject
    on QueryBuilder<UdharEntry, UdharEntry, QFilterCondition> {}

extension UdharEntryQueryLinks
    on QueryBuilder<UdharEntry, UdharEntry, QFilterCondition> {}

extension UdharEntryQuerySortBy
    on QueryBuilder<UdharEntry, UdharEntry, QSortBy> {
  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByIGave() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iGave', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByIGaveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iGave', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByIsSettled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSettled', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByIsSettledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSettled', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy>
      sortByLinkedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTransactionId', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy>
      sortByLinkedTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTransactionId', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortBySettledAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAmount', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortBySettledAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAmount', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortBySettledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortBySettledVia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledVia', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortBySettledViaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledVia', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortBySettlementNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settlementNote', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy>
      sortBySettlementNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settlementNote', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension UdharEntryQuerySortThenBy
    on QueryBuilder<UdharEntry, UdharEntry, QSortThenBy> {
  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByIGave() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iGave', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByIGaveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iGave', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByIsSettled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSettled', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByIsSettledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSettled', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy>
      thenByLinkedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTransactionId', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy>
      thenByLinkedTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTransactionId', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenBySettledAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAmount', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenBySettledAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAmount', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenBySettledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledAt', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenBySettledVia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledVia', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenBySettledViaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settledVia', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenBySettlementNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settlementNote', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy>
      thenBySettlementNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settlementNote', Sort.desc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension UdharEntryQueryWhereDistinct
    on QueryBuilder<UdharEntry, UdharEntry, QDistinct> {
  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByIGave() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iGave');
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByIsSettled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSettled');
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByLinkedTransactionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedTransactionId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByPersonName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctBySettledAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settledAmount');
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctBySettledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settledAt');
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctBySettledVia(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settledVia', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctBySettlementNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settlementNote',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UdharEntry, UdharEntry, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension UdharEntryQueryProperty
    on QueryBuilder<UdharEntry, UdharEntry, QQueryProperty> {
  QueryBuilder<UdharEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UdharEntry, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<UdharEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UdharEntry, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<UdharEntry, bool, QQueryOperations> iGaveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iGave');
    });
  }

  QueryBuilder<UdharEntry, bool, QQueryOperations> isSettledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSettled');
    });
  }

  QueryBuilder<UdharEntry, String?, QQueryOperations>
      linkedTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedTransactionId');
    });
  }

  QueryBuilder<UdharEntry, String, QQueryOperations> personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personName');
    });
  }

  QueryBuilder<UdharEntry, String?, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<UdharEntry, String, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<UdharEntry, double?, QQueryOperations> settledAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settledAmount');
    });
  }

  QueryBuilder<UdharEntry, DateTime?, QQueryOperations> settledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settledAt');
    });
  }

  QueryBuilder<UdharEntry, String?, QQueryOperations> settledViaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settledVia');
    });
  }

  QueryBuilder<UdharEntry, String?, QQueryOperations> settlementNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settlementNote');
    });
  }

  QueryBuilder<UdharEntry, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
