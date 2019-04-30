// @flow
import React from 'react';

type DataItem = {
  key: string,
  label: string,
  value: string,
};

type Props = {
  title: string,
  data: DataItem[],
};

export const ComponentWithTypedProps = (props: Props) => (
  <div>
    <h2>{props.title}</h2>
    <ul>
      {props.data.map(({ key, label, value }) => (
        <li key={key} title={value}>{label}</li>
      ))}
    </ul>
  </div>
);

export default ComponentWithTypedProps;
