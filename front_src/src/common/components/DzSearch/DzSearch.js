// @flow
import React, { useState } from 'react';
import { Input, Button } from 'antd';

import type {TDzSearchOptions} from "../../types";

import "./DzSearch.styles.scss";

type Props = {
  renderItems: () => React.node,
  handleSearch: (options: TDzSearchOptions) => void,
  searchIsLoading: boolean,
};

export const DzSearch = (props: Props) => {
  const [ query, setQuery ] = useState('');
  const { renderItems, searchIsLoading, handleSearch } = props;

  const handleInputChange = (e) => {
    setQuery(e.target.value);
  };

  const parseQuery = (): TDzSearchOptions => {
    if (!query) {
      return null;
    }

    const queryObject: TDzSearchOptions = {};
    const parts = query.split('&&').map(v => v.trim());

    for (let searchPart of parts) {
      const keyValuePair = searchPart.split(":").map(v => v.trim().toLowerCase());

      if (keyValuePair.length === 1) {
        const [value] = keyValuePair;

        Object.assign(queryObject, { track: value });
      }

      if (keyValuePair.length === 2) {
        const [key, value] = keyValuePair;

        Object.assign(queryObject, { [key]: value });
      }
    }

    return queryObject;
  };

  return (
    <div className="dz-search-container">
      <div className="dz-search-bar">
        <Input onChange={handleInputChange} value={query}/>
        <Button
          loading={searchIsLoading}
          disabled={searchIsLoading}
          onClick={() => {
            const queryObject = parseQuery();

            if (queryObject) {
              handleSearch(queryObject);
            }
          }}
        >
          Fetch
        </Button>
      </div>
      { renderItems() }
    </div>
  );
};

export default DzSearch;
