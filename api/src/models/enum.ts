export enum Functions {
  AVG = "AVG",
  COUNT = "COUNT",
  MIN = "MIN",
  MAX = "MAX",
  SUM = "SUM",
}
export enum COP {
  eq = "eq",
  ne = "ne",
  gt = "gt",
  lt = "lt",
  ge = "ge",
  le = "le",
  in = "in",
  ni = "ni",
  like = "like",  
}
export enum LOP {
  AND = "AND",
  OR = "OR",
}

export enum Type {
  CROSS = "CROSS",
  INNER = "INNER",
  LEFT_OUTER = "LEFT_OUTER",
  RIGHT_OUTER = "RIGHT_OUTER",
  FULL_OUTER = "FULL_OUTER",
}
 
export enum UserRole {
  ANONYMOUS ="ANONYMOUS",
  STUDENT = "STUDENT",
  INSTRUCTOR = "INSTRUCTOR",
  ADMINISTRATOR = "ADMINISTRATOR",
  GUEST = "GUEST",
}

export enum Status {
  ACTIVE = "ACTIVE",
  INACTIVE = "INACTIVE",
  DELETED = "DELETED",
}