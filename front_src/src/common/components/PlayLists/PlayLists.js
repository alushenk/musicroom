// @flow
import React, { PureComponent } from 'react';
import { Icon, Table, Input, Button } from 'antd';
import { Link } from 'react-router-dom';
import Highlighter from 'react-highlight-words';

const getRestictionsRow = (_, record) => {
  const restrictionTexts = [];

  if (!record.is_public) {
    restrictionTexts.push('Private');
  }
  if (record.place) {
    restrictionTexts.push('Location Restricted');
  }
  if (record.time_from || record.time_to) {
    restrictionTexts.push('Time Restricted');
  }

  // TODO: add tooltip to show restriction data
  return restrictionTexts.length ? (
    <div className="indicators-wrapper">
      <Icon
        type="check-circle"
        className="indicator-icon"
        title={restrictionTexts.join(' - ')}
      />
    </div>
  ) : null;
};

const columns = [
  {
    title: 'Id',
    dataIndex: 'id',
    key: 'id',
    width: '10%',
  },
  {
    title: 'Name',
    dataIndex: 'name',
    key: 'name',
    width: '25%',
    render: (text, record) => (
      <span>
        <Link to={`/playlists/${record.id}`}>
          {text}
        </Link>
      </span>
    ),
  },
  {
    title: 'Public',
    dataIndex: 'is_public',
    key: 'is_public',
    width: '15%`',
    render: (_, record) => (
      <span>{record.is_public.toString()}</span>
    ),
  },
  {
    title: 'Restricted',
    dataIndex: 'hasRestrictions',
    key: 'hasRestrictions',
    width: '10%`',
    render: getRestictionsRow,
  }
];

const paginationConfig = {
  hideOnSinglePage: true,
  showSizeChanger: true,
};

type Props = {
  playlists: [],
};
type State = {
  searchText: string,
};

export class PlayLists extends PureComponent<Props, State> {
  state = {
    searchText: '',
  };

  getColumnSearchProps = (dataIndex) => ({
    filterDropdown: ({ setSelectedKeys, selectedKeys, confirm, clearFilters }) => (
      <div style={{ padding: 8 }}>
        <Input
          ref={node => { this.searchInput = node; }}
          placeholder={`Search ${dataIndex}`}
          value={selectedKeys[0]}
          onChange={e => setSelectedKeys(e.target.value ? [e.target.value] : [])}
          onPressEnter={() => this.handleSearch(selectedKeys, confirm)}
          style={{ width: 188, marginBottom: 8, display: 'block' }}
        />
        <Button
          type="primary"
          onClick={() => this.handleSearch(selectedKeys, confirm)}
          icon="search"
          size="small"
          style={{ width: 90, marginRight: 8 }}
        >
          Search
        </Button>
        <Button
          onClick={() => this.handleReset(clearFilters)}
          size="small"
          style={{ width: 90 }}
        >
          Reset
        </Button>
      </div>
    ),
    filterIcon: filtered => <Icon type="search" style={{ color: filtered ? '#1890ff' : undefined }} />,
    onFilter: (value, record) => record[dataIndex].toString().toLowerCase().includes(value.toLowerCase()),
    onFilterDropdownVisibleChange: (visible) => {
      if (visible) {
        setTimeout(() => this.searchInput.select());
      }
    },
    render: (text, record) => (
      <Link to={`/playlists/${record.id}`}>
        <Highlighter
          highlightStyle={{ backgroundColor: '#ffc069', padding: 0 }}
          searchWords={[this.state.searchText]}
          autoEscape
          textToHighlight={text.toString()}
        />
      </Link>
    ),
  });

  handleSearch = (selectedKeys, confirm) => {
    confirm();
    this.setState({ searchText: selectedKeys[0] });
  };

  handleReset = (clearFilters) => {
    clearFilters();
    this.setState({ searchText: '' });
  };

  render() {
    const {
      playlists,
    } = this.props;

    Object.assign(columns[1], {...this.getColumnSearchProps('name')});

    return (
      <Table
        rowKey={record => `album-item-${record.id}`}
        columns={columns}
        dataSource={playlists}
        rowClassName="album-record"
        pagination={paginationConfig}
      />
    );
  }
}

export default PlayLists;
