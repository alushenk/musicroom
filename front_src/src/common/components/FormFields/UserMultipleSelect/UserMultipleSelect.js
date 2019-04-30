// @flow
import React from 'react';
import { Select, Form } from 'antd';

const { Option } = Select;
const { Item: FormItem } = Form;

type Props = {
  users: [],
  form: {},
  formFieldName: string,
  label: string | React.node,
  rules?: {}[],
  onSelectHandler: () => Promise<any>,
  onDeselectHandler: () => Promise<any>,
};

const UserMultipleSelect = (props: Props) => {
  const {
    form: {
      getFieldValue,
      // setFieldsValue,
      getFieldDecorator,
    },
    users,
    formFieldName,
    label,
    onSelectHandler = () => Promise.resolve(),
    onDeselectHandler = () => Promise.resolve(),
  } = props;

  const getFullName = (user) => {
    const { first_name, second_name } = user;
    let title = first_name || second_name;

    if (!(first_name || second_name)) {
      title = 'Name is not specified';
    } else if (first_name && second_name) {
      title = `${first_name} ${second_name}`;
    }

    return title;
  };

  const handleSelect = (value) => {
    // const prevValues = getFieldValue(formFieldName);

    onSelectHandler(Number(value));
    // onSelectHandler(Number(value))
    //   .then(() => setFieldsValue({ [formFieldName]: [...prevValues, value] }))
    //   .catch((error) => console.log(error));
  };

  const handleDeselect = (value) => {
    // const prevValues = getFieldValue(formFieldName);


    onDeselectHandler(Number(value));
    // onDeselectHandler(Number(value))
    //   .then(() => setFieldsValue({ [formFieldName]: prevValues.filter(v => v !== value) }))
    //   .catch((error) => console.log(error));
  };

  getFieldDecorator(formFieldName);

  return (
    <div id={`form-field-${formFieldName}`}>
      <FormItem label={label}>
        <Select
          value={getFieldValue(formFieldName)}
          showSearch={true}
          optionFilterProp="search-value"
          mode="multiple"
          notFoundContent="No users found..."
          placeholder="Select users..."
          onSelect={handleSelect}
          onDeselect={handleDeselect}
          getPopupContainer={() => document.getElementById(`form-field-${formFieldName}`)}
        >
          {users.map((user) => (
            <Option key={user.id} search-value={user.username} title={getFullName(user)} value={user.id}>
              {user.username}
            </Option>
          ))}
        </Select>
      </FormItem>
    </div>
  );
};

export default UserMultipleSelect;
