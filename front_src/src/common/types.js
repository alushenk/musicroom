// @flow

export type TDzAlbum = {
  id: number,
  title: string,
};

export type TDzArtist = {
  id: number,
  name: string,
};

export type TPlayListUserStatuses = {
  subscribed: boolean,
  owner: boolean,
  creator: boolean,
};

export type TDzSearchOptions = {
  artist: string,
  album: string,
  track: string,
  label: string,
  dur_min: number,
  dur_max: number,
};

export type TTracksRecord = {
  id: number,
  data: {},
};

export type TLocationCoordinate = {
  lat: number,
  lon: number,
  radius?: number,
};
