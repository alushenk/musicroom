// @flow
import React, {Component, Fragment} from 'react';
import {Form, Button, Input, DatePicker, Icon, message} from 'antd';
import { toJS } from 'mobx';
import { observer, inject } from 'mobx-react';
import LocationPicker from 'react-location-picker';
import moment from 'moment';
import get from 'lodash.get';

import SwitchField from "../FormFields/SwitchField";
import DzSearch from "../DzSearch/DzSearch";
import PlayList from "../PlayList/PlayList";
import UserMultipleSelect from "../FormFields/UserMultipleSelect/UserMultipleSelect";

import {ASYNC_STATE, PLAY_LIST_DATA_FORM_FIELDS} from "../../constants";

import type {TracksStore} from "../../../stores/tracksStore";
import type {SettingsStore} from "../../../stores/settingsStore";
import type {TTracksRecord} from "../../types";
import type {PlaylistsStore} from "../../../stores/playlistsStore";

const formId = 'play-list-data-form';
const formFields = PLAY_LIST_DATA_FORM_FIELDS;

const defaultPosition = { lat: 50.4507, lng: 30.5230 };

type Props = {
  isCreateForm?: boolean,
  playListItem?: {},
  handleSubmit: () => void,
  tracksStore: TracksStore,
  settingsStore: SettingsStore,
  playlistsStore: PlaylistsStore,
};
type State = {
  tracks: TTracksRecord[],

  address: string,
  position: {
    lat: number,
    lng: number,
  },
};

export class PlayListData extends Component<Props, State> {
  state = {
    tracks: [],
    address: "Maidan Nezalezhnosti, 2, Kyiv, Ukraine, 02000",
    position: {
      ...defaultPosition
    },
  };

  fieldsToValidate = [formFields.name, formFields.locationRadius];

  componentDidMount = () => {
    const { settingsStore } = this.props;

    settingsStore.getUsers();

    this.setState({
      position: this.getDefaultLocation(),
    });
  };

  handleLocationChange = ({ position, address }) => {
    this.setState({ position, address });
  };

  addTrackToList = (newTrack: TTracksRecord) => {
    const { tracks } = this.state;
    const trackItem = tracks.find(({ id }) => id === newTrack.id);

    if (trackItem) {
      message.warning('Tracks duplicates are forbidden.');
    } else {
      this.setState((prevState) => ({
        tracks: [
          ...prevState.tracks,
          newTrack,
        ],
      }));
    }
  };

  removeTrackFromListById = (removeId: number) => {
    this.setState((prevState) => ({
      tracks: prevState.tracks.filter(({ id }) => id !== removeId),
    }))
  };

  normalizeFormValues = (values) => {
    const { tracks, position } = this.state;
    const { isCreateForm } = this.props;

    const body = {
      name: values[formFields.name],
      is_public: values[formFields.isPublic],
      place: values[formFields.hasLocationRestriction] ?
        {
          lat: Number(position.lat),
          lon: Number(position.lng),
          radius: Number(values[formFields.locationRadius])
        } :
        null,
      ...(values[formFields.hasTimeRestriction] ? {
        time_from: values[formFields.timeFrom],
        time_to: values[formFields.timeTo],
      } : {
        time_from: null,
        time_to: null,
      })
    };

    if (!isCreateForm) {
      return body;
    }

    Object.assign(body, {
      tracks: tracks.map(({ data }) => data),
    });

    return body;
  };

  handleOk = () => {
    const { form, handleSubmit } = this.props;

    form.validateFields(this.fieldsToValidate, (errors) => {
      if (!errors) {
        const normalizedValues = this.normalizeFormValues(form.getFieldsValue());

        handleSubmit(normalizedValues);
      }
    })
  };

  userSelectOnSelect = (userRole) => (userId: number) => {
    const {
      isCreateForm,
      playlistsStore,
      playListItem,
    } = this.props;

    if (!isCreateForm) {
      if (userRole === 'participant') {
        return playlistsStore.playlistParticipant(playListItem.id, userId, 'add')
      } else if (userRole === 'owner') {
        return playlistsStore.playlistOwner(playListItem.id, userId, 'add');
      }
    }

    return Promise.resolve();
  };

  userSelectOnDeselect = (userRole) => (userId: number) => {
    const {
      isCreateForm,
      playlistsStore,
      playListItem,
    } = this.props;

    if (!isCreateForm) {
      if (userRole === 'participant') {
        return playlistsStore.playlistParticipant(playListItem.id, userId, 'remove')
      } else if (userRole === 'owner') {
        return playlistsStore.playlistOwner(playListItem.id, userId, 'remove');
      }
    }

    return Promise.resolve();
  };

  getDefaultLocation = () => {
    const { playListItem } = this.props;

    const [lat, lng] = [
      get(playListItem, ['place', 'lat']) || defaultPosition.lat,
      get(playListItem, ['place', 'lon']) || defaultPosition.lng,
    ];

    return { lat, lng };
  };

  getDefaultDateProp = (fieldName) => {
    const { playListItem } = this.props;
    const defaultProps = {};
    const time = get(playListItem, fieldName, undefined);

    // TODO: check for unsafe moment parse
    if (time) {
      Object.assign(defaultProps, { defaultValue: moment(time) });
    }

    return defaultProps;
  };

  render() {
    const { tracks } = this.state;
    const { form, tracksStore, settingsStore, isCreateForm } = this.props;

    const hasTimeRestriction = form.getFieldValue(formFields.hasTimeRestriction);
    const hasLocationRestriction = form.getFieldValue(formFields.hasLocationRestriction);

    if (hasLocationRestriction) {
      this.fieldsToValidate = [formFields.name, formFields.locationRadius];
    } else {
      this.fieldsToValidate = [formFields.name];
    }

    form.getFieldDecorator(formFields.timeFrom);
    form.getFieldDecorator(formFields.timeTo);

    const allUsers = toJS(settingsStore.allUsers);

    form.getFieldDecorator(formFields.participants);

    return (
      <Form id={formId}>
        <Form.Item label="Playlist name:">
          {form.getFieldDecorator(formFields.name, {
            validateFirst: true,
            rules: [
              { required: true, message: 'Name is required.' },
              { max: 255, message: 'Maximum length is 255 symbols.' },
            ]
          })(
            <Input placeholder="Name your playlist..."/>
          )}
        </Form.Item>

        {!isCreateForm && (
          <UserMultipleSelect
            users={allUsers}
            form={form}
            formFieldName={formFields.participants}
            label="Participants:"
            onSelectHandler={this.userSelectOnSelect('participant')}
            onDeselectHandler={this.userSelectOnDeselect('participant')}
          />
        )}

        {!isCreateForm && (
          <UserMultipleSelect
            users={allUsers}
            form={form}
            formFieldName={formFields.owners}
            label="Participants with owner permissions:"
            onSelectHandler={this.userSelectOnSelect('owner')}
            onDeselectHandler={this.userSelectOnDeselect('owner')}
          />
        )}

        <SwitchField
          form={form}
          label="Check if your playlist is public"
          fieldName={formFields.isPublic}
        />

        <SwitchField
          form={form}
          label="Time restricted"
          fieldName={formFields.hasTimeRestriction}
        />

        {hasTimeRestriction && (
          <div className='date-range-picker-container'>
            <DatePicker
              showTime={{ format: 'HH:mm' }}
              {...this.getDefaultDateProp(formFields.timeFrom)}
              getCalendarContainer={() => document.getElementById(formId)}
              format="YYYY-MM-DD HH:mm"
              placeholder={'Time From'}
              onChange={(value) => {
                const dateISO = value._d.toISOString();

                form.setFields({
                  [formFields.timeFrom]: { touched: true, value: dateISO },
                });
              }}
            />

            <DatePicker
              showTime={{ format: 'HH:mm' }}
              {...this.getDefaultDateProp(formFields.timeTo)}
              getCalendarContainer={() => document.getElementById(formId)}
              format="YYYY-MM-DD HH:mm"
              placeholder={'Time To'}
              onChange={(value) => {
                const dateISO = value._d.toISOString();

                form.setFields({
                  [formFields.timeTo]: { touched: true, value: dateISO },
                });
              }}
            />
          </div>
        )}

        <SwitchField
          form={form}
          label="Location restricted"
          fieldName={formFields.hasLocationRestriction}
        />

        <div className={`location-picker-container${!hasLocationRestriction ? ' hidden' : ''}`}>
          <LocationPicker
            containerElement={ <div style={ {height: '100%'} } /> }
            mapElement={ <div style={ {height: '400px'} } /> }
            defaultPosition={this.getDefaultLocation()}
            onChange={this.handleLocationChange}
            radius={Number(form.getFieldValue(formFields.locationRadius)) || 100}
            zoom={17}
          />

          <Form.Item label="Availability radius:">
            {form.getFieldDecorator(formFields.locationRadius, {
              validateFirst: true,
              rules: [
                { validator: (_, value, cb) => {
                    value.toString().length > 5 ? cb(true) : cb();
                  }, message: 'Maximum length is 5 symbols.' },
                { pattern: /^\d+$/, message: 'Must be a positive integer.' },
                { validator: (_, value, cb) => {
                    Number(value) < 25 ? cb(true) : cb();
                  },
                  message: 'Must be at least 25 meters.'
                }
              ]
            })(
              <Input
                placeholder="Availability radius..."
              />
            )}
          </Form.Item>
        </div>

        {/* Added to playlist tracks */}
        {isCreateForm && (
          <Fragment>
            <PlayList
              playlistId={null}
              items={tracks}
              configureActionColumn={() => ({
                title: 'Action',
                key: 'action',
                width: '15%`',
                className: 'ant-actions-column',
                render: ({ id }) => (
                  <div className="actions-container">
                    <Icon type="minus-circle" className="action-icon" onClick={() => this.removeTrackFromListById(id)}/>
                  </div>
                ),
              })}
            />

            <DzSearch
              renderItems={() => (
                <PlayList
                  playlistId={null}
                  items={tracksStore.searchResultTracks}
                  configureActionColumn={() => ({
                    title: 'Action',
                    key: 'action',
                    width: '15%`',
                    className: 'ant-actions-column',
                    render: (record) => (
                      <div className="actions-container">
                        <Icon type="plus-circle" className="action-icon" onClick={() => this.addTrackToList(record)}/>
                      </div>
                    ),
                  })}
                />
              )}
              handleSearch={tracksStore.searchTracks}
              searchIsLoading={tracksStore.searchAsyncState === ASYNC_STATE.pending}
            />
          </Fragment>
        )}

        <Button type="primary" onClick={this.handleOk}>
          Submit
        </Button>
      </Form>
    );
  }
}

const mapPropsToFields = (props: Props) => {
  const { playListItem } = props;
  const {
    name,
    participants,
    owners,
    hasTimeRestriction,
    timeFrom,
    timeTo,
    isPublic,
    hasLocationRestriction,
    locationRadius,
  } = formFields;

  const newPlayList = {
    [name]: 'Test Play Lists Name',
    [isPublic]: true,
    [owners]: [],
    [participants]: [],
    [hasTimeRestriction]: false,
    [timeFrom]: null,
    [timeTo]: null,
    [hasLocationRestriction]: false,
    [locationRadius]: 100,
  };

  const playListData = (playListItem && playListItem instanceof Object) ?
    Object.assign({}, newPlayList, playListItem, {
      [hasLocationRestriction]: Boolean(playListItem.place),
      [hasTimeRestriction]: Boolean(playListItem.time_from) || Boolean(playListItem.time_to),
      [locationRadius]: get(playListItem, ['place', 'radius'], 100),
    }) :
    newPlayList;

  return {
    [name]: Form.createFormField({ value: playListData[name] }),
    [isPublic]: Form.createFormField({ value: playListData[isPublic] }),
    [owners]: Form.createFormField({ value: playListData[owners] }),
    [participants]: Form.createFormField({ value: playListData[participants] }),
    [hasTimeRestriction]: Form.createFormField({ value: playListData[hasTimeRestriction] }),
    [timeFrom]: Form.createFormField({ value: playListData[timeFrom] }),
    [timeTo]: Form.createFormField({ value: playListData[timeTo] }),
    [hasLocationRestriction]: Form.createFormField({ value: playListData[hasLocationRestriction] }),
    [locationRadius]: Form.createFormField({ value: playListData[locationRadius] }),
  };
};

const PlayListDataForm = Form.create({
  mapPropsToFields,
})(observer(PlayListData));

export default inject('playlistsStore', 'tracksStore', 'settingsStore')(
  observer(PlayListDataForm)
);
