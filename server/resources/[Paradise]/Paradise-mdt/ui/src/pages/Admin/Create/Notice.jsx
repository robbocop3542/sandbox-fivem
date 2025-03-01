import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Grid, TextField, MenuItem, Backdrop, ButtonGroup, Button } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { useNavigate } from 'react-router';
import { toast } from 'react-toastify';

import { usePermissions } from '../../../hooks';

import Nui from '../../../util/Nui';
import { Loader, Editor } from '../../../components';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		padding: '20px 10px 20px 20px',
		height: '95%',
	},
	editorField: {
		marginBottom: 10,
	},
	option: {
		transition: 'background ease-in 0.15s',
		border: `1px solid ${theme.palette.border.divider}`,
		'&:hover': {
			background: theme.palette.secondary.main,
			cursor: 'pointer',
		},
		'&.selected': {
			color: theme.palette.primary.main,
		},
	},
	calculator: {
		height: '100%',
	},
	col: {
		height: '100%',
		overflowY: 'auto',
		overflowX: 'hidden',
		padding: 5,
	},
	positiveButton: {
		borderColor: `${theme.palette.success.main}80`,
		color: theme.palette.success.main,
		'&:hover': {
			borderColor: theme.palette.success.main,
			background: `${theme.palette.success.main}14`,
		},
	},
	popup: {
		maxHeight: `750px !important`,
	},
}));

const initialState = {
	title: '',
	description: '',
};

export default (props) => {
	const classes = useStyles();
	const history = useNavigate();
	const dispatch = useDispatch();
	const hasPerm = usePermissions();
	const myJob = useSelector(state => state.app.govJob);

	const governmentJobs = useSelector((state) => state.data.data.governmentJobs);
	const allJobData = useSelector((state) => state.data.data.governmentJobsData);

	const postPublic = hasPerm('DOJ_JUDGE') || hasPerm('GOV_MAYOR') || hasPerm('GOV_DA');

	const [restricted, setRestricted] = useState(myJob.Id);
	const [loading, setLoading] = useState(false);
	const [state, setState] = useState({
		...initialState,
	});

	const onChange = (e) => {
		setState({ ...state, [e.target.name]: e.target.value });
	};

	const onSubmit = async (e) => {
		e.preventDefault();

		try {
			let res = await await Nui.send('Create', {
				type: 'notice',
				doc: {
					...state,
					restricted,
				},
			});

			if (res) {
				toast.success('Notice Created');
				history(-1);
			} else {
				toast.error('Unable to Create Notice');
			}
		} catch (err) {
			console.log(err);
			toast.error('Unable to Create Notice');
		}
	};

	const onCancel = () => {
		history(-1);
	};

	return (
		<div className={classes.wrapper}>
			<Backdrop open={loading} style={{ zIndex: 100 }}>
				<Loader text="Loading" />
			</Backdrop>
			<form onSubmit={onSubmit}>
				<Grid container style={{ height: '100%' }}>
					<Grid item xs={12} className={classes.col}>
						<TextField
							required
							fullWidth
							variant="standard"
							className={classes.editorField}
							label="Notice Title"
							name="title"
							value={state.title}
							onChange={onChange}
							inputProps={{ maxLength: 64 }}
						/>
						<TextField
							select
							fullWidth
							variant="standard"
							label="Restrict Notice"
							className={classes.editorField}
							value={restricted}
							onChange={(e) => setRestricted(e.target.value)}
						>
							{postPublic && <MenuItem key={'public'} value={'public'}>
								Public Records Notice
							</MenuItem>}
							{governmentJobs.filter(j => myJob.Id == j || hasPerm(true)).map((j) => (
								<MenuItem key={j} value={j}>
									{allJobData[j]?.Name ?? 'Unknown'}
								</MenuItem>
							))}
						</TextField>
						<Editor
							allowMedia
							name="description"
							title="Notice"
							placeholder={'Enter Notice'}
							disabled={loading}
							value={state.description}
							onChange={(e) => {
								setState({ ...state, description: e.target.value });
							}}
						/>
					</Grid>
					<Grid item xs={12} className={classes.col}>
						<ButtonGroup fullWidth>
							<Button onClick={onCancel}>Go Back</Button>
							<Button type="submit">Create Notice</Button>
						</ButtonGroup>
					</Grid>
				</Grid>
			</form>
		</div>
	);
};
