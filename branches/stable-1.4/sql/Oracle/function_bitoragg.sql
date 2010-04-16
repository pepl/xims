create or replace type BitOrAggImpl as object
(
  cur NUMBER,
  zero NUMBER,
  static function ODCIAggregateInitialize(sctx IN OUT BitOrAggImpl)
    return number,
  member function ODCIAggregateIterate(self IN OUT BitOrAggImpl,
    value IN number) return number,
  member function ODCIAggregateTerminate(self IN BitOrAggImpl,
    returnValue OUT number, flags IN number) return number,
  member function ODCIAggregateMerge(self IN OUT BitOrAggImpl,
    ctx2 IN BitOrAggImpl) return number
);
/

create or replace type body BitOrAggImpl is
static function ODCIAggregateInitialize(sctx IN OUT BitOrAggImpl)
return number is
begin
  sctx := BitOrAggImpl(1,0);
  return ODCIConst.Success;
end;

member function ODCIAggregateIterate(self IN OUT BitOrAggImpl, value IN number) return number is
begin
  if value = 0 then
    self.zero := 1;
  else
    self.cur := self.cur - bitand(self.cur,value) + value;
  end if;
  return ODCIConst.Success;
end;

member function ODCIAggregateTerminate(self IN BitOrAggImpl,
    returnValue OUT number, flags IN number) return number is
begin
  if self.zero = 1 then
    returnValue := 0;
  else
    returnValue := self.cur;
  end if;
  return ODCIConst.Success;
end;

member function ODCIAggregateMerge(self IN OUT BitOrAggImpl, ctx2 IN BitOrAggImpl) return number is
begin
  if ctx2.cur = 0 then
    self.zero := 1;
  else
    self.cur := self.cur - bitand(self.cur,ctx2.cur) + ctx2.cur;
  end if;
  return ODCIConst.Success;
end;
end;
/

create or replace function BitOrAgg (input NUMBER) return number
PARALLEL_ENABLE AGGREGATE USING BitOrAggImpl;
/
