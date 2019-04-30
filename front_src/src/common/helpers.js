// @flow
import { message } from 'antd';
import get from 'lodash.get';
import {
  AUTH_LOCAL_STORAGE_FIELDS,
  GENERAL_ERROR_MESSAGE,
  GENERAL_FORM_FIELD_ERROR,
  NO_PERMISSIONS_API_MESSAGE
} from "./constants";

import type {TLocationCoordinate, TTracksRecord} from "./types";

export const safeGetCurrentUserId = (): number => {
  const localStoreUserId = Number(localStorage.getItem(AUTH_LOCAL_STORAGE_FIELDS.userId));

  if (isFinite(localStoreUserId) && !isNaN(localStoreUserId) && localStoreUserId > 0) {
      return localStoreUserId;
  }

  return null;
};

export const normalizeDzTrackCollection = (tracks): TTracksRecord[] => {
  return tracks.map((trackData) => {
    const { id, readable, title, album, artist, duration } = trackData;

    return {
      id,
      data: {
        readable,
        id,
        title,
        album: {
          id: album.id,
          title: album.title,
          cover: album.cover,
        },
        artist: {
          id: artist.id,
          name: artist.name,
        },
        duration,
      }
    }
  });
};

const letters = 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split('');
export const generateStringQuery = (length: number = 3) => {
  const res = [];
  const lettersLenght = letters.length;

  for(let i = 0; i < length; i++) {
    const idx = Math.floor(Math.random() * lettersLenght);

    res.push(letters[idx]);
  }

  return res.join('');
};

export const degreesToRadians = (degrees: number) => {
  return degrees * Math.PI / 180;
};

export const distanceInKmBetweenEarthCoordinates = (first: TLocationCoordinate, second: TLocationCoordinate) => {
  const earthRadiusKm = 6371;

  const dLat = degreesToRadians(Math.abs(second.lat - first.lat));
  const dLon = degreesToRadians(Math.abs(second.lon - first.lon));

  const latFirst = degreesToRadians(first.lat);
  const latSecond = degreesToRadians(second.lat);

  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(latFirst) * Math.cos(latSecond);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return earthRadiusKm * c;
};

export const locationHasChanged = (first: TLocationCoordinate, second: TLocationCoordinate) => {
  if (first && second) {
    if (first.radius !== second.radius) {
      return true;
    } else if (Math.floor(first.lat * 10000) !== Math.floor(second.lat * 10000)) {
      return true;
    } else if (Math.floor(first.lon * 10000) !== Math.floor(second.lon * 10000)) {
      return true;
    }

    return false;
  } else if (!first && !second) {
    return false;
  }

  return true;
};

export const transferResponseErrorsToForm = (form, e) => {
  const data = get(e.response, 'data');

  if (data) {
    const fields = Object.entries(data).reduce((acc, [ key, value ]) => {
      const fieldValue = form.getFieldValue(key);

      if (!fieldValue) {
        return acc;
      }

      let errorText = GENERAL_FORM_FIELD_ERROR;

      if (value instanceof String) {
        errorText = value;
      } else if (Array.isArray(value)) {
        errorText = value.join(' ');
      }

      return {
        ...acc,
        [key]: { value: fieldValue, errors: [ { message: errorText } ] },
      };
    }, {});

    form.setFields(fields);
  }
};

export const handleNonFieldErrors = (e) => {
  const data = get(e.response, 'data') || {};
  console.log(data);
  const errorTexts = get(data, 'non_field_errors') || GENERAL_ERROR_MESSAGE;

  let errorText = errorTexts;

  if (Array.isArray(errorTexts)) {
    errorText = errorTexts.join(' ');
  }

  message.error(errorText);
};

export const handleGetApiError = (e) => {
  const [
    status,
    data,
  ] = [
    get(e, ['response', 'status']),
    get(e, ['response', 'data']) || {}
  ];

  if (status === 403 && data.detail === NO_PERMISSIONS_API_MESSAGE) {
    message.info('You have no access to this content.');

    return true;
  }

  return false;
};

export const noop = () => {};

export const localStorageCredentialsPresent = () => {
  const token = localStorage.getItem(AUTH_LOCAL_STORAGE_FIELDS.token);

  return token && safeGetCurrentUserId();
};
