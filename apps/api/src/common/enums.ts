export enum UserRole {
  PLAYER = 'PLAYER',
  VENUE_OWNER = 'VENUE_OWNER',
  REFEREE = 'REFEREE',
  ADMIN = 'ADMIN'
}

export enum BookingStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  CANCELLED = 'CANCELLED',
  COMPLETED = 'COMPLETED'
}

export enum HoldStatus {
  ACTIVE = 'ACTIVE',
  RELEASED = 'RELEASED',
  SETTLED = 'SETTLED',
  CANCELLED = 'CANCELLED'
}

export enum LedgerEntryType {
  CREDIT = 'CREDIT',
  DEBIT = 'DEBIT'
}
