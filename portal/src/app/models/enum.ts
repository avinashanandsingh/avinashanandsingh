export enum UserRole {
  ANONYMOUS = 'ANONYMOUS',
  STUDENT = 'STUDENT',
  INSTRUCTOR = 'INSTRUCTOR',
  ADMINISTRATOR = 'ADMINISTRATOR',
  GUEST = 'GUEST',
}

export enum Status {
  ACTIVE = 'ACTIVE',
  APPROVED = 'APPROVED',
  CANCELLED = 'CANCELLED',
  DELETED = 'DELETED',
  INACTIVE = 'INACTIVE',
  PENDING = 'PENDING',
  REJECTED = 'REJECTED',
}

export enum CourseStatus {
  PUBLISHED = 'PUBLISHED',
  DRAFT = 'DRAFT',
  ARCHIVED = 'ARCHIVED',
}

export enum COP {
  eq = 'eq',
  ne = 'ne',
  gt = 'gt',
  lt = 'lt',
  ge = 'ge',
  le = 'le',
  in = 'in',
  ni = 'ni',
  like = 'like',
}

export enum LOP {
  AND = 'AND',
  OR = 'OR',
}
