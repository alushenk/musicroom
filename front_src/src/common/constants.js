export const constImages = {
  albumCoverFallbackUrl: 'https://fallback.png',
};

export const webSocketBase = 'wss://musicroom.ml/ws';
export const WEB_SOCKET_MESSAGE_TYPES = {
  refresh: 'refresh',
  delete: 'delete',
};

export const NO_PERMISSIONS_API_MESSAGE = 'You do not have permission to perform this action.';
export const TRACK_DUPLICATE_API_MESSAGE = 'Track already exists';
export const GENERAL_ERROR_MESSAGE = 'Something went wrong, please try again later.';
export const GENERAL_FORM_FIELD_ERROR = 'Field has errors.';

export const AUTH_FORM_FIELDS = {
  userName: 'username',
  password: 'password',
  repeatPassword: 'repeatPassword',
  email: 'email',
  formActionType: 'formActionType'
};

export const PROFILE_FORM_FIELDS = {
  userName: 'username',
  firstName: 'first_name',
  secondName: 'last_name',
  email: 'email',

  newPassword: 'new_password1',
  repeatNewPassword: 'new_password2',
};

export const PLAY_LIST_DATA_FORM_FIELDS = {
  name: 'name',
  isPublic: 'is_public',
  participants: 'participants',
  owners: 'owners',
  hasTimeRestriction: 'hasTimeRestriction',
  timeFrom: 'time_from',
  timeTo: 'time_to',
  hasLocationRestriction: 'hasLocationRestriction',
  location: 'location',
  locationRadius: 'radius',
};

export const AUTH_FORM_ACTION_TYPES = {
  login: 'login',
  register: 'register',
};

export const ASYNC_STATE = {
  pending: 'pending',
  done: 'done',
};

export const AUTH_LOCAL_STORAGE_FIELDS = {
  token: 'mr-api-token',
  userId: 'mr-user-id',
};
