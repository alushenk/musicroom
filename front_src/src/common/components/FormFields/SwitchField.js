// @flow
import React from 'react';
import { Switch, Form } from 'antd';

const FormItem = Form.Item;

type Props = {
  form: {},
  label: string | React.node,
  fieldName: string,
};

export const SwitchField = (props: Props) => {
  const {
    label,
    fieldName,
    form: {
      getFieldDecorator,
      getFieldValue,
      setFieldsValue,
    }
  } = props;

  getFieldDecorator(fieldName);

  return (
    <FormItem label={label}>
      <Switch
        checked={getFieldValue(fieldName)}
        onClick={(value) => setFieldsValue({ [fieldName]: value })}
      />
    </FormItem>
  );
};

export default SwitchField;