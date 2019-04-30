// @flow
import React, { Component } from 'react';
import { Spin, Form, Input, Select } from 'antd';
import { inject, observer } from 'mobx-react';

import {ASYNC_STATE} from "../../common/constants";

import type {PlaylistsStore} from "../../stores/playlistsStore";

const FormItem = Form.Item;

type Props = {
  playlistsStore: PlaylistsStore,
};
type State = {};
export class PlayListEditPage extends Component<Props, State> {
  // componentDidMount = () => {
  //   console.log(this.props);
  // };

  render() {
    const { playlistsStore } = this.props;

    return (
      <div className="content-outer-container">
        <Spin spinning={playlistsStore.asyncState === ASYNC_STATE.pending}>
          <Form>
            <FormItem label="Play List Title">
              <Input/>
            </FormItem>

            <FormItem label="Keywords">
              <Select></Select>
            </FormItem>
          </Form>
        </Spin>
      </div>
    );
  }
}

export default inject('playlistsStore')(observer(PlayListEditPage));
