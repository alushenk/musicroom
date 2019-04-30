import React, { useState } from 'react';
import { Table, Icon, Popover, Button } from 'antd';
import get from 'lodash.get';

import DzPlayTracksActionButton from "../DzPlayTracksActionButton/DzPlayTracksActionButton";
import TrackLikeButton from "../TrackLikeButton/TrackLikeButton";
import {noop, safeGetCurrentUserId} from "../../helpers";
import {constImages} from "../../constants";

import type {PlaylistsStore} from "../../../stores/playlistsStore";

import './PlayList.styles.scss';

const columns = [
  {
    title: 'Artist',
    dataIndex: 'artist',
    key: 'artist',
    width: '15%',
    render: (text, record) => get(record.data, ['artist', 'name'], 'no-artist'),
  },
  {
    title: 'Album',
    dataIndex: 'album',
    key: 'album',
    width: '15%`',
    render: (text, record) => get(record.data, ['album', 'title'], 'no-album'),
  },
  {
    title: 'Album Cover',
    dataIndex: 'albumCover',
    key: 'albumCover',
    width: '15%`',
    render: (text, record) => (
      <img
        alt="album-cover"
        className='album-cover-small'
        src={get(record.data, ['album', 'cover'], constImages.albumCoverFallbackUrl)}
      />
    ),
  },
];
const paginationConfig = {
  hideOnSinglePage: true,
  showSizeChanger: true,
};

type Props = {
  playlistId: number,
  playlistsStore?: PlaylistsStore,
  items: {}[],
  // userStatusOptions: TPlayListUserStatuses,
  withSelectableRows?: boolean,
  selectedItem?: number,
  handleItemSelect?: () => void,
  configureActionColumn: () => {},
  showRatingColumn?: boolean,
  onPlaySideEffect: () => void,
}

export const PlayList = (props: Props) => {
  const [ activePopoverId, setActivePopoverId ] = useState(null);
  const {
    playlistId,
    playlistsStore = {},
    items,
    withSelectableRows,
    selectedItem,
    handleItemSelect,
    configureActionColumn,
    showRatingColumn,
    onPlaySideEffect = noop,
  } = props;

  const dzTrackIds = items.map((item) => item.data.id);
  const actionTitleColumn = {
    title: 'Title',
    dataIndex: 'title',
    key: 'title',
    width: '15%',
    render: (text, record, index) => {
      return (
        <div className="track-record-title">
          {get(record.data, 'title', 'no-title')}
          <div className="title-play-button">
            <DzPlayTracksActionButton
              onClickSideEffect={onPlaySideEffect}
              trackIds={dzTrackIds}
              startTrackIndex={index}
            />
          </div>
        </div>
      );
    },
  };

  const columnsWithTitle = [
    actionTitleColumn,
    ...columns,
  ];

  if (showRatingColumn) {
    columnsWithTitle.push({
      title: 'Rating',
      dataIndex: 'rating',
      key: 'rating',
      className: 'ant-rating-column',
      width: '15%',
      render: (text, record) => {
        const votes = get(record, 'votes', []);
        // TODO: rewrite to use getUserData endpoint to not rely on local storage
        const currentUserId: number = safeGetCurrentUserId();

        if (!currentUserId) {
          return null;
        }

        const currentUserLikeObject = votes.find(({ user }) => Number(user) === currentUserId);

        const buttonProps = currentUserLikeObject ? {
          iconType: 'dislike',
          onClick: () => playlistsStore.voteTrack(record.id, playlistId, true),
        } : {
          iconType: 'like',
          onClick: () => playlistsStore.voteTrack(record.id, playlistId),
        };

        return (
          <div className="track-record-rating">
            <span className="track-rating-likes">{votes.length}</span>
            <TrackLikeButton {...buttonProps}/>
          </div>
        );
      },
    });
  }

  const columnsWithAction = [
    ...columnsWithTitle,
    configureActionColumn ?
      configureActionColumn(activePopoverId, setActivePopoverId) :
      {
        title: 'Action',
        key: 'action',
        width: '15%`',
        render: ({ id }) => (
        <Popover
          content={
            <div>
              <p>Select playlist</p>
              {/*<PlayListSelectField playlists={playlists}/>*/}
              <Button type="primary" onClick={() => console.log('Add to selected playlist')}>
                Add
              </Button>
            </div>
          }
          arrowPointAtCenter={true}
          title="Title"
          trigger="click"
          visible={id === activePopoverId}
          onVisibleChange={(visible) => setActivePopoverId(visible ? id : null)}
        >
          <Icon type="plus-circle" className="action-icon"/>
        </Popover>
      ),
    },
  ];

  const additionalProps = withSelectableRows ? {
    onRow: (record) => ({
      onClick: () => handleItemSelect(record.id),
    }),
  } : {};

  return (
    <Table
      rowKey={record => `track-item-${record.id}`}
      columns={columnsWithAction}
      dataSource={items}
      rowClassName={(record) => {
        // TODO: use classnames here
        if (withSelectableRows && record.id === selectedItem) {
          return 'track-record active'
        }

        return 'track-record';
      }}
      {...additionalProps}
      pagination={paginationConfig}
    />
  );
};

export default PlayList;
