// @flow
import React from 'react';
import { Select } from 'antd';

import './PlayListSelectField.styles.scss';

const { Option } = Select;

type Props = {
  // tracksStore: TracksStore,
  playlists: [],
};

export const PlayListSelectField = (props: Props) => {
  const { playlists } = props;

  return (
    <Select
      className="album-select-wrap"
      showSearch={true}
      allowClear={true}
      mode="multiple"
      placeholder="Select play lists..."
      optionFilterProp="title"
    >
      {playlists.map(({ id, name }) => (
        <Option key={id} title={name}>
          {name}
        </Option>
      ))}
    </Select>
  );
};

export default PlayListSelectField;
